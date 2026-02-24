import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../../domain/entities/order.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc()..add(LoadOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Commandes'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is OrderOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderLoaded) {
              if (state.orders.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucune commande', style: TextStyle(fontSize: 18)),
                      Text('Appuyez sur + pour créer une commande'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                itemBuilder: (context, index) => _buildOrderCard(context, state.orders[index]),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final paymentProgress = order.montantPaye / order.montantTotal;
    
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
                      Text('Commande #${order.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${order.stockVariety} (${order.stockCategory})', style: TextStyle(color: Colors.grey[600])),
                      Text('Acheteur: ${order.buyerName}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (!order.isDelivered) const PopupMenuItem(value: 'deliver', child: Text('Marquer livré')),
                    const PopupMenuItem(value: 'payment', child: Text('Mettre à jour paiement')),
                  ],
                  onSelected: (value) {
                    if (value == 'deliver') {
                      context.read<OrderBloc>().add(MarkOrderDelivered(order.id));
                    } else if (value == 'payment') {
                      _showPaymentDialog(context, order);
                    }
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.isDelivered ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.isDelivered ? 'Livré' : 'En cours',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
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
                    Text('${(paymentProgress * 100).toInt()}%', style: const TextStyle(fontSize: 10)),
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

  void _showCreateOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OrderFormDialog(),
    );
  }

  void _showPaymentDialog(BuildContext context, Order order) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: ${order.montantTotal} BIF'),
            Text('Déjà payé: ${order.montantPaye} BIF'),
            Text('Restant: ${order.montantTotal - order.montantPaye} BIF'),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Montant payé'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                context.read<OrderBloc>().add(UpdatePayment(order.id, amount));
                Navigator.pop(context);
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
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
  final _buyerController = TextEditingController();
  final _varietyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle Commande'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _buyerController,
              decoration: const InputDecoration(labelText: 'Nom de l\'acheteur'),
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
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
          child: const Text('Créer'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final orderData = {
        'buyer_name': _buyerController.text,
        'variety': _varietyController.text,
        'quantity': double.parse(_quantityController.text),
        'price': int.parse(_priceController.text),
      };

      context.read<OrderBloc>().add(CreateOrder(orderData));
      Navigator.pop(context);
    }
  }
}
