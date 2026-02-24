import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/loss_bloc.dart';
import '../../domain/entities/loss.dart';

class LossesListPage extends StatelessWidget {
  const LossesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LossBloc()..add(LoadLosses()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pertes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/losses/add'),
            ),
          ],
        ),
        body: BlocConsumer<LossBloc, LossState>(
          listener: (context, state) {
            if (state is LossError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is LossOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is LossLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LossLoaded) {
              return Column(
                children: [
                  // Summary Card
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
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${state.totalLoss.toStringAsFixed(0)} BIF',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.trending_down, size: 48, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                  // Losses List
                  Expanded(
                    child: state.losses.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Aucune perte enregistrée'),
                                Text('Appuyez sur + pour ajouter une perte'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
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
        title: Text(loss.stockVariety),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantité: ${loss.quantite}'),
            if (loss.details != null) Text('Détails: ${loss.details}'),
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
