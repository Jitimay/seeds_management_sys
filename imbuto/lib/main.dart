import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app.dart';
import 'core/storage/storage_service.dart';
import 'core/services/offline_service.dart';
import 'shared/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize services
  await ServiceLocator.init();
  
  // Initialize storage
  await StorageService.init();
  
  // Initialize offline service
  await OfflineService.init();
  
  runApp(const ImbutoApp());
}
