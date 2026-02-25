import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void showWarning(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is String) return error;

    // Handle different error types
    if (error.toString().contains('SocketException')) {
      return 'Problème de connexion internet';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Délai d\'attente dépassé';
    }

    if (error.toString().contains('401')) {
      return 'Session expirée, veuillez vous reconnecter';
    }

    if (error.toString().contains('403')) {
      return 'Accès non autorisé';
    }

    if (error.toString().contains('404')) {
      return 'Ressource non trouvée';
    }

    if (error.toString().contains('500')) {
      return 'Erreur du serveur';
    }

    return 'Une erreur inattendue s\'est produite';
  }
}

class GlobalErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const GlobalErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Une erreur s\'est produite',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
