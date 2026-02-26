import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/services/service_locator.dart';
import '../bloc/order_bloc.dart';
import '../../domain/entities/order.dart';
import '../../../stocks/data/datasources/stock_api_service.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_state.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== ORDERS PAGE OPENED ===');
    return BlocProvider(
      create: (context) => ServiceLocator.get<OrderBloc>()..add(LoadOrders()),
      child: Builder(
        builder: (context) => BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final bool isCultivateur = authState is AuthAuthenticated &&
                authState.user['types'] == 'cultivateurs';

            return Scaffold(
              appBar: AppBar(
                title: Text(isCultivateur ? 'Mes Achats' : 'Mes Commandes'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _showCreateOrderDialog(context),
                  ),
                ],
              ),
              body: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderError) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else if (state is OrderOperationSuccess) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderLoaded) {
                    if (state.orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                                isCultivateur
                                    ? 'Aucun achat effectué'
                                    : 'Aucune commande',
                                style: const TextStyle(fontSize: 18)),
                            const Text('Appuyez sur + pour créer une commande'),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) => _buildOrderCard(
                          context, state.orders[index], authState),
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

  Widget _buildOrderCard(
      BuildContext context, Order order, AuthState authState) {
    final paymentProgress = order.montantPaye / order.montantTotal;

    String otherPartyLabel = 'Acheteur';
    String otherPartyName = order.buyerName;

    if (authState is AuthAuthenticated) {
      final currentUsername = authState.user['username'];
      if (order.buyerName == currentUsername) {
        otherPartyLabel = 'Vendeur';
        otherPartyName = order.sellerName;
      }
    }

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
                      Text('Commande #${order.id}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${order.stockVariety} (${order.stockCategory})',
                          style: TextStyle(color: Colors.grey[600])),
                      Text('$otherPartyLabel: $otherPartyName',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _buildOrderActions(context, order, authState),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantité: ${order.quantity}'),
                      Text('Prix unitaire: ${order.prixUnitaire} BIF'),
                      Text('Total: ${order.montantTotal} BIF'),
                      Text('Payé: ${order.montantPaye} BIF'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.isDelivered ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.isDelivered ? 'Livré' : 'En cours',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: paymentProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          paymentProgress >= 1.0 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    Text('${(paymentProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Créé le ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            if (order.deliveredDate != null)
              Text(
                'Livré le ${order.deliveredDate!.day}/${order.deliveredDate!.month}/${order.deliveredDate!.year}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(
      BuildContext context, Order order, AuthState authState) {
    // Only show actions if user is NOT a simple buyer (Cultivateur)
    // OR if it's their own order and they need to update something?
    // Usually, the seller (Multiplicateur) updates delivery and payments.

    final bool isCultivateur = authState is AuthAuthenticated &&
        authState.user['types'] == 'cultivateurs';

    // We hide actions for Cultivateurs for now as they are buyers
    if (isCultivateur) return const SizedBox.shrink();

    /* return PopupMenuButton<String>(
      itemBuilder: (context) => [
        if (!order.isDelivered)
          const PopupMenuItem(value: 'deliver', child: Text('Marquer livré')),
        const PopupMenuItem(
            value: 'payment', child: Text('Mettre à jour paiement')),
      ],
      onSelected: (value) {
        if (value == 'deliver') {
          context.read<OrderBloc>().add(MarkOrderDelivered(order.id));
        } else if (value == 'payment') {
          _showPaymentDialog(context, order);
        }
      },
    ); */
    return const SizedBox.shrink();
  }

  void _showCreateOrderDialog(BuildContext context) {
    final orderBloc = context.read<OrderBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: orderBloc,
        child: const OrderFormDialog(),
      ),
    );
  }
}

class OrderFormDialog extends StatefulWidget {
  const OrderFormDialog({super.key});

  @override
  State<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<OrderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  List<Map<String, dynamic>> _stocks = [];
  int? _selectedStockId;
  bool _loadingStocks = true;
  double? _availableQuantity;
  int? _unitPrice;

  @override
  void initState() {
    super.initState();
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    try {
      final stockApiService = ServiceLocator.get<StockApiService>();
      final stocks = await stockApiService.getStocksPublic();
      if (mounted) {
        setState(() {
          _stocks = stocks;
          _loadingStocks = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingStocks = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle Commande'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loadingStocks
            ? const SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator()))
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedStockId,
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
                        onChanged: (value) {
                          final selectedStock =
                              _stocks.firstWhere((s) => s['id'] == value);
                          setState(() {
                            _selectedStockId = value;
                            _availableQuantity =
                                (selectedStock['qte_restante'] as num)
                                    .toDouble();
                            _unitPrice =
                                selectedStock['prix_vente_unitaire'] as int;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Sélectionner le lot de semences'),
                        validator: (value) =>
                            value == null ? 'Sélectionnez un stock' : null,
                      ),
                      if (_unitPrice != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Prix: $_unitPrice BIF/kg',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                            labelText: 'Quantité à commander (kg)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
                          final qty = double.tryParse(value);
                          if (qty == null) return 'Nombre invalide';
                          if (qty <= 0) return 'La quantité doit être positive';
                          if (_availableQuantity != null &&
                              qty > _availableQuantity!) {
                            return 'Stock insuffisant ($_availableQuantity kg max)';
                          }
                          return null;
                        },
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
        TextButton(
          onPressed: _loadingStocks ? null : _submitForm,
          child: const Text('Créer'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: 'Création de la commande en cours...',
          backgroundColor: Colors.blue);

      final orderData = {
        'stock': _selectedStockId,
        'quantite': double.parse(_quantityController.text),
      };

      context.read<OrderBloc>().add(CreateOrder(orderData));
      Navigator.pop(context);
    }
  }
}
