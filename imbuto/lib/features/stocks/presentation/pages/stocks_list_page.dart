import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/stock_bloc.dart';
import '../../domain/entities/stock.dart';

class StocksListPage extends StatelessWidget {
  const StocksListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc()..add(LoadStocks()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Stocks'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddStockDialog(context),
            ),
          ],
        ),
        body: BlocConsumer<StockBloc, StockState>(
          listener: (context, state) {
            if (state is StockError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is StockOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is StockLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StockLoaded) {
              if (state.stocks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun stock disponible', style: TextStyle(fontSize: 18)),
                      Text('Appuyez sur + pour ajouter un stock'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.stocks.length,
                itemBuilder: (context, index) => _buildStockCard(context, state.stocks[index]),
              );
            }
            return const SizedBox();
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
                      Text(stock.varietyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${stock.plantName} - ${stock.category}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
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
                        Text('Expire: ${stock.dateExpiration!.day}/${stock.dateExpiration!.month}/${stock.dateExpiration!.year}'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    showDialog(
      context: context,
      builder: (context) => const StockFormDialog(),
    );
  }

  void _showEditStockDialog(BuildContext context, Stock stock) {
    showDialog(
      context: context,
      builder: (context) => StockFormDialog(stock: stock),
    );
  }

  void _confirmDelete(BuildContext context, int stockId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce stock ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<StockBloc>().add(DeleteStock(stockId));
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
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
  final _varietyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Base';

  @override
  void initState() {
    super.initState();
    if (widget.stock != null) {
      _varietyController.text = widget.stock!.varietyName;
      _quantityController.text = widget.stock!.qteTotal.toString();
      _priceController.text = widget.stock!.prixVenteUnitaire.toString();
      _selectedCategory = widget.stock!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.stock == null ? 'Ajouter un stock' : 'Modifier le stock'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Pré_Bases', 'Base', 'Certifiés'].map((cat) => 
                DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            TextFormField(
              controller: _varietyController,
              decoration: const InputDecoration(labelText: 'Variété'),
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantité'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Prix unitaire (BIF)'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: _submitForm,
          child: Text(widget.stock == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final stockData = {
        'category': _selectedCategory,
        'variety_name': _varietyController.text,
        'qte_totale': double.parse(_quantityController.text),
        'prix_vente_unitaire': int.parse(_priceController.text),
      };

      if (widget.stock == null) {
        context.read<StockBloc>().add(CreateStock(stockData));
      } else {
        context.read<StockBloc>().add(UpdateStock(widget.stock!.id, stockData));
      }
      Navigator.pop(context);
    }
  }
}
