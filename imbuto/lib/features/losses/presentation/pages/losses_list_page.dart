import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../shared/services/service_locator.dart';
import '../../../stocks/data/datasources/stock_api_service.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/loss_bloc.dart';

class LossesListPage extends StatelessWidget {
  const LossesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LossBloc()..add(LoadLosses()),
      child: Builder(
        builder: (context) => BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final bool isCultivateur = authState is AuthAuthenticated &&
                authState.user['types'] == 'cultivateurs';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Pertes'),
                actions: [
                  if (!isCultivateur)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddLossDialog(context),
                    ),
                ],
              ),
              body: BlocConsumer<LossBloc, LossState>(
                listener: (context, state) {
                  if (state is LossError) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else if (state is LossOperationSuccess) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is LossLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LossLoaded) {
                    return Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total des pertes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      '${state.totalLoss.toStringAsFixed(0)} BIF',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.trending_down,
                                    size: 48, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: state.losses.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text('Aucune perte enregistrée'),
                                      Text(
                                          'Appuyez sur + pour ajouter une perte'),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: state.losses.length,
                                  itemBuilder: (context, index) {
                                    final loss = state.losses[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        onTap: () => _showLossDetails(context, loss),
                                        borderRadius: BorderRadius.circular(12),
                                        child: ListTile(
                                          title: Text(loss.stockVariety ??
                                              'Stock inconnu'),
                                          subtitle: Text(
                                              'Quantité: ${loss.quantite} kg\nDate: ${loss.createdAt.day}/${loss.createdAt.month}/${loss.createdAt.year}'),
                                          trailing: Text(
                                            '${loss.montantPerdu.toStringAsFixed(0)} BIF',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          isThreeLine: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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

  void _showAddLossDialog(BuildContext context) {
    final lossBloc = context.read<LossBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: lossBloc,
        child: const LossFormDialog(),
      ),
    );
  }

  void _showLossDetails(BuildContext context, dynamic loss) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la perte'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Semence', loss.stockVariety ?? 'Stock inconnu'),
              _buildDetailRow('Quantité perdue', '${loss.quantite} kg'),
              _buildDetailRow('Montant perdu', '${loss.montantPerdu.toStringAsFixed(0)} BIF'),
              _buildDetailRow(
                'Date',
                '${loss.createdAt.day}/${loss.createdAt.month}/${loss.createdAt.year}',
              ),
              if (loss.details != null && loss.details.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Raison:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(loss.details),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class LossFormDialog extends StatefulWidget {
  const LossFormDialog({super.key});

  @override
  State<LossFormDialog> createState() => _LossFormDialogState();
}

class _LossFormDialogState extends State<LossFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  List<Map<String, dynamic>> _stocks = [];
  int? _selectedStockId;
  bool _loadingStocks = true;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    try {
      print('📱 Loading stocks for loss dialog...');
      final stockApiService = ServiceLocator.get<StockApiService>();
      final stocks = await stockApiService.getStocks();
      print('📱 Loaded ${stocks.length} stocks for loss dialog');
      if (mounted) {
        setState(() {
          _stocks = stocks;
          _loadingStocks = false;
        });
      }
    } catch (e) {
      print('📱 Error loading stocks for loss dialog: $e');
      if (mounted) {
        setState(() => _loadingStocks = false);
        Fluttertoast.showToast(
          msg: 'Erreur lors du chargement des stocks: ${e.toString()}',
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
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enregistrer une perte'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loadingStocks
            ? const SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator()))
            : _stocks.isEmpty
                ? SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning, size: 48, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun stock disponible',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Veuillez créer et valider des stocks d\'abord',
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
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        items: _stocks
                            .where((s) => s['validated_at'] != null)
                            .map((s) => DropdownMenuItem<int>(
                                  value: s['id'] as int,
                                  child: Text(
                                    '${s['variety_info']?['nom'] ?? 'Inconnu'} - ${s['category']} (${s['qte_restante']} kg dispo)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedStockId = value),
                        decoration: const InputDecoration(
                            labelText: 'Sélectionner le stock'),
                        validator: (value) =>
                            value == null ? 'Sélectionnez un stock' : null,
                      ),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                            labelText: 'Quantité perdue (kg)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
                          if (double.tryParse(value) == null) return 'Invalide';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(labelText: 'Raison'),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
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
        if (!_loadingStocks && _stocks.isNotEmpty)
          TextButton(
            onPressed: _submitForm,
            child: const Text('Enregistrer'),
          ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<LossBloc>().add(AddLoss(
            stockId: _selectedStockId!,
            quantite: int.parse(_quantityController.text),
            details: _reasonController.text,
          ));
      Navigator.pop(context);
    }
  }
}
