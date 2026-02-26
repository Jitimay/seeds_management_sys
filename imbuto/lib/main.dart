import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app.dart';
import 'core/storage/storage_service.dart';
import 'core/services/offline_service.dart';
import 'shared/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Initialize Hive
    await Hive.initFlutter();
    
    // 2. Initialize storage service
    await StorageService.init();
    
    // 3. Initialize service locator (includes TokenManager and ApiClient)
    await ServiceLocator.init();
    
    // 4. Initialize offline service
    await OfflineService.init();
    
    // 5. Run app
    runApp(const ImbutoApp());
  } catch (e) {
    // Handle initialization errors
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Initialization Error: $e'),
            ],
          ),
        ),
      ),
    ));
  }
}
