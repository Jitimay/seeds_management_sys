import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imbuto/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/plant_bloc.dart';
import '../../domain/entities/plant.dart';

class PlantsListPage extends StatelessWidget {
  const PlantsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlantBloc()..add(LoadPlants()),
      child: Builder(
        builder: (context) => BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final bool isCultivateur = authState is AuthAuthenticated &&
                authState.user['types'] == 'cultivateurs';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Plantes'),
                actions: [
                  if (!isCultivateur)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddPlantDialog(context),
                    ),
                ],
              ),
              body: BlocConsumer<PlantBloc, PlantState>(
                listener: (context, state) {
                  if (state is PlantError) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else if (state is PlantOperationSuccess) {
                    Fluttertoast.showToast(
                      msg: state.message,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PlantLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PlantLoaded) {
                    if (state.plants.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Aucune plante disponible'),
                            Text('Appuyez sur + pour ajouter une plante'),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: state.plants.length,
                      itemBuilder: (context, index) {
                        final plant = state.plants[index];
                        return _PlantCard(plant: plant);
                      },
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

  void _showAddPlantDialog(BuildContext context) {
    final plantBloc = context.read<PlantBloc>();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: plantBloc,
        child: AlertDialog(
          title: const Text('Ajouter une plante'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nom de la plante',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  plantBloc.add(AddPlant(controller.text));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;
  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Icon(Icons.eco, size: 64, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${plant.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
