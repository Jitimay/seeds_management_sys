import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/services/service_locator.dart';
import '../../domain/entities/admin_validation.dart';
import '../bloc/admin_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ServiceLocator.get<AdminBloc>()..add(LoadPendingValidations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AdminBloc>().add(LoadPendingValidations());
              },
            ),
          ],
        ),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is AdminOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Multiplicateurs',
                            count: state.pendingMultiplicators.length,
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () => _showValidationList(
                                context,
                                'Multiplicateurs en attente',
                                state.pendingMultiplicators),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Stocks',
                            count: state.pendingStocks.length,
                            icon: Icons.inventory,
                            color: Colors.green,
                            onTap: () => _showValidationList(context,
                                'Stocks en attente', state.pendingStocks),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Rôles',
                            count: state.pendingRoles.length,
                            icon: Icons.admin_panel_settings,
                            color: Colors.orange,
                            onTap: () => _showValidationList(context,
                                'Rôles en attente', state.pendingRoles),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Container()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (state.pendingMultiplicators.isEmpty &&
                        state.pendingStocks.isEmpty &&
                        state.pendingRoles.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.check_circle,
                                size: 64, color: Colors.green),
                            SizedBox(height: 16),
                            Text('Aucune validation en attente'),
                            Text('Toutes les demandes ont été traitées'),
                          ],
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Actions rapides',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Utilisez l\'interface d\'administration Django pour valider les demandes en lot.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Open Django admin in webview or external browser
                                },
                                icon: const Icon(Icons.admin_panel_settings),
                                label: const Text('Ouvrir Admin Django'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showValidationList(
      BuildContext context, String title, List<PendingValidation> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.subtitle),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.createdAt.day}/${item.createdAt.month}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline,
                                  color: Colors.green),
                              onPressed: () {
                                Navigator.pop(context); // Close bottom sheet
                                context
                                    .read<AdminBloc>()
                                    .add(ValidateItem(item.id, item.type));
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Show detailed view
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
