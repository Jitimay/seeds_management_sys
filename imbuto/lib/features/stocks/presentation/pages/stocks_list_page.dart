import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imbuto/features/stocks/data/datasources/stock_api_service.dart';
import '../../../../shared/services/service_locator.dart';
import '../bloc/stock_bloc.dart';
import '../../domain/entities/stock.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_state.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StocksListPage extends StatelessWidget {
  const StocksListPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== STOCKS PAGE OPENED ===');
    return BlocProvider(
      create: (context) => ServiceLocator.get<StockBloc>()..add(LoadStocks()),
      child: Builder(
        // Builder gives us a context that is BELOW the BlocProvider,
        // allowing _showAddStockDialog to correctly call context.read<StockBloc>()
        builder: (context) => BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final bool isCultivateur = authState is AuthAuthenticated &&
                authState.user['types'] == 'cultivateurs';

            return Scaffold(
              appBar: AppBar(
                title:
                    Text(isCultivateur ? 'Catalogue Semences' : 'Mes Stocks'),
                actions: [
                  if (!isCultivateur)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddStockDialog(context),
                    ),
                ],
              ),
              body: BlocConsumer<StockBloc, StockState>(
                listener: (context, state) {
                  if (state is StockError) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else if (state is StockOperationSuccess) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StockLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StockLoaded) {
                    if (state.stocks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                                isCultivateur
                                    ? 'Aucune semence disponible'
                                    : 'Aucun stock disponible',
                                style: const TextStyle(fontSize: 18)),
                            if (!isCultivateur)
                              const Text('Appuyez sur + pour ajouter un stock'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.stocks.length,
                      itemBuilder: (context, index) =>
                          _buildStockCard(context, state.stocks[index]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, Stock stock) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stock.varietyName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${stock.plantName} - ${stock.category}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    // const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Supprimer')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') _showEditStockDialog(context, stock);
                    if (value == 'delete') _confirmDelete(context, stock.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantité: ${stock.qteRestante}/${stock.qteTotal}'),
                      Text('Prix: ${stock.prixVenteUnitaire} BIF'),
                      if (stock.dateExpiration != null)
                        Text(
                            'Expire: ${stock.dateExpiration!.day}/${stock.dateExpiration!.month}/${stock.dateExpiration!.year}'),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stock.isValidated ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stock.isValidated ? 'Validé' : 'En attente',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStockDialog(BuildContext context) {
    final stockBloc = context.read<StockBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: stockBloc,
        child: const StockFormDialog(),
      ),
    );
  }

  void _showEditStockDialog(BuildContext context, Stock stock) {
    final stockBloc = context.read<StockBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: stockBloc,
        child: StockFormDialog(stock: stock),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int stockId) {
    final stockBloc = context.read<StockBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: stockBloc,
        child: AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce stock ?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                stockBloc.add(DeleteStock(stockId));
              },
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class StockFormDialog extends StatefulWidget {
  final Stock? stock;
  const StockFormDialog({super.key, this.stock});

  @override
  State<StockFormDialog> createState() => _StockFormDialogState();
}

class _StockFormDialogState extends State<StockFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Pré_Bases';

  List<Map<String, dynamic>> _varieties = [];
  int? _selectedVarietyId;
  bool _loadingVarieties = true;

  @override
  void initState() {
    super.initState();
    _loadVarieties();
    if (widget.stock != null) {
      _quantityController.text = widget.stock!.qteTotal.toString();
      _priceController.text = widget.stock!.prixVenteUnitaire.toString();
      _selectedCategory = widget.stock!.category;
    }
  }

  Future<void> _loadVarieties() async {
    try {
      print('📱 Loading varieties for stock dialog...');
      final apiService = ServiceLocator.get<StockApiService>();
      final varieties = await apiService.getVarieties();
      print('📱 Loaded ${varieties.length} varieties for stock dialog');
      if (mounted) {
        setState(() {
          _varieties = varieties;
          if (widget.stock != null && varieties.isNotEmpty) {
            // Try to pre-select the variety of the stock being edited
            final match =
                varieties.where((v) => v['nom'] == widget.stock!.varietyName);
            if (match.isNotEmpty) _selectedVarietyId = match.first['id'];
          }
          _loadingVarieties = false;
        });
      }
    } catch (e) {
      print('📱 Error loading varieties for stock dialog: $e');
      if (mounted) {
        setState(() => _loadingVarieties = false);
        Fluttertoast.showToast(
          msg: 'Erreur lors du chargement des variétés: ${e.toString()}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.stock == null ? 'Ajouter un stock' : 'Modifier le stock'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loadingVarieties
            ? const SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator()))
            : _varieties.isEmpty
                ? SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning, size: 48, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune variété disponible',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Veuillez créer des variétés d\'abord',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: ['Pré_Bases', 'Base', 'Certifiés']
                            .map((cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value!),
                        decoration:
                            const InputDecoration(labelText: 'Catégorie'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        items: _varieties
                            .map((v) => DropdownMenuItem<int>(
                                  value: v['id'] as int,
                                  child: Text(
                                    '${v['nom'] ?? 'Inconnu'} (${v['plant_name'] ?? ''})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedVarietyId = value),
                        decoration: const InputDecoration(labelText: 'Variété'),
                        validator: (value) =>
                            value == null ? 'Sélectionnez une variété' : null,
                      ),
                      TextFormField(
                        controller: _quantityController,
                        decoration:
                            const InputDecoration(labelText: 'Quantité'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Requis' : null,
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                            labelText: 'Prix unitaire (BIF)'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty == true ? 'Requis' : null,
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        if (!_loadingVarieties && _varieties.isNotEmpty)
          TextButton(
            onPressed: _submitForm,
            child: Text(widget.stock == null ? 'Ajouter' : 'Modifier'),
          ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: 'Création du stock en cours...', backgroundColor: Colors.blue);
      print('Submitting stock form...');
      final stockData = {
        'category': _selectedCategory,
        'variety': _selectedVarietyId,
        'qte_totale': double.parse(_quantityController.text),
        'prix_vente_unitaire': int.parse(_priceController.text),
      };

      print('Stock data: $stockData');

      if (widget.stock == null) {
        context.read<StockBloc>().add(CreateStock(stockData));
      } else {
        context.read<StockBloc>().add(UpdateStock(widget.stock!.id, stockData));
      }
      Navigator.pop(context);
    }
  }
}
