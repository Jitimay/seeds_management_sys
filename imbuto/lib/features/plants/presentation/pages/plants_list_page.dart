import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../bloc/plant_bloc.dart';
import '../../domain/entities/plant.dart';

class PlantsListPage extends StatelessWidget {
  const PlantsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlantBloc()..add(LoadPlants()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Plantes'),
            actions: [
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            ElevatedButton(
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
      child: InkWell(
        onTap: () {
          // TODO: Navigate to plant details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Expanded(
                child: Center(
                  child: Icon(Icons.eco, size: 48, color: Colors.green),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                plant.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${plant.id}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
