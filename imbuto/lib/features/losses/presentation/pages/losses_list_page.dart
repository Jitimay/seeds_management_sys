import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../shared/services/service_locator.dart';
import '../../../stocks/data/datasources/stock_api_service.dart';
import '../bloc/loss_bloc.dart';
import '../../domain/entities/loss.dart';

class LossesListPage extends StatelessWidget {
  const LossesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LossBloc()..add(LoadLosses()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Pertes'),
            actions: [
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                                  Text('Appuyez sur + pour ajouter une perte'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.losses.length,
                              itemBuilder: (context, index) {
                                final loss = state.losses[index];
                                return _LossCard(loss: loss);
                              },
                            ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _showAddLossDialog(BuildContext context) {
    final lossBloc = context.read<LossBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: lossBloc,
        child: const _LossFormDialog(),
      ),
    );
  }
}

class _LossFormDialog extends StatefulWidget {
  const _LossFormDialog();

  @override
  State<_LossFormDialog> createState() => _LossFormDialogState();
}

class _LossFormDialogState extends State<_LossFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _detailsController = TextEditingController();

  List<Map<String, dynamic>> _stocks = [];
  int? _selectedStockId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    try {
      final stockApi = ServiceLocator.get<StockApiService>();
      final stocks = await stockApi.getStocks();
      if (mounted) {
        setState(() {
          // Filter only validated stocks
          _stocks = stocks.where((s) => s['validated_by'] != null).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enregistrer une perte'),
      content: _loading
          ? const SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedStockId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      items: _stocks.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['id'] as int,
                          child: Text(
                            '${s['variety_info']?['nom'] ?? 'Variété inconnue'} (${s['category']})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedStockId = val),
                      validator: (val) =>
                          val == null ? 'Veuillez choisir un stock' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Quantité perdue'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requis';
                        if (int.tryParse(val) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _detailsController,
                      decoration: const InputDecoration(labelText: 'Détails'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<LossBloc>().add(AddLoss(
            stockId: _selectedStockId!,
            quantite: int.parse(_quantityController.text),
            details: _detailsController.text.isEmpty
                ? null
                : _detailsController.text,
          ));
      Navigator.pop(context);
    }
  }
}

class _LossCard extends StatelessWidget {
  final Loss loss;

  const _LossCard({required this.loss});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.remove, color: Colors.white),
        ),
        title: Text(
          loss.stockVariety ?? 'Variété inconnue',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantité: ${loss.quantite}'),
            if (loss.details != null)
              Text(
                'Détails: ${loss.details}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              'Date: ${loss.createdAt.day}/${loss.createdAt.month}/${loss.createdAt.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          '${loss.montantPerdu.toStringAsFixed(0)} BIF',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
