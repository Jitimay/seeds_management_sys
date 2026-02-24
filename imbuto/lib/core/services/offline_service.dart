import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineService {
  static late Box _offlineBox;
  static const String _offlineActionsKey = 'offline_actions';
  
  static Future<void> init() async {
    _offlineBox = await Hive.openBox('offline_data');
  }
  
  // Queue offline actions
  static Future<void> queueAction(Map<String, dynamic> action) async {
    final actions = getQueuedActions();
    actions.add({
      ...action,
      'timestamp': DateTime.now().toIso8601String(),
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    await _offlineBox.put(_offlineActionsKey, actions);
  }
  
  static List<Map<String, dynamic>> getQueuedActions() {
    final actions = _offlineBox.get(_offlineActionsKey, defaultValue: <dynamic>[]);
    return List<Map<String, dynamic>>.from(actions);
  }
  
  static Future<void> clearQueuedActions() async {
    await _offlineBox.delete(_offlineActionsKey);
  }
  
  static Future<void> removeAction(String actionId) async {
    final actions = getQueuedActions();
    actions.removeWhere((action) => action['id'] == actionId);
    await _offlineBox.put(_offlineActionsKey, actions);
  }
  
  // Cache data
  static Future<void> cacheData(String key, dynamic data) async {
    await _offlineBox.put('cache_$key', {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static T? getCachedData<T>(String key, {Duration? maxAge}) {
    final cached = _offlineBox.get('cache_$key');
    if (cached == null) return null;
    
    if (maxAge != null) {
      final timestamp = DateTime.parse(cached['timestamp']);
      if (DateTime.now().difference(timestamp) > maxAge) {
        _offlineBox.delete('cache_$key');
        return null;
      }
    }
    
    return cached['data'] as T?;
  }
  
  // Connectivity
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  static Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}

class SyncService {
  static Future<void> syncOfflineActions() async {
    if (!await OfflineService.isOnline()) return;
    
    final actions = OfflineService.getQueuedActions();
    
    for (final action in actions) {
      try {
        await _processAction(action);
        await OfflineService.removeAction(action['id']);
      } catch (e) {
        // Log error but continue with other actions
        print('Failed to sync action ${action['id']}: $e');
      }
    }
  }
  
  static Future<void> _processAction(Map<String, dynamic> action) async {
    switch (action['type']) {
      case 'create_stock':
        // TODO: Implement stock creation API call
        break;
      case 'create_order':
        // TODO: Implement order creation API call
        break;
      case 'add_loss':
        // TODO: Implement loss creation API call
        break;
      case 'add_rating':
        // TODO: Implement rating creation API call
        break;
      default:
        throw Exception('Unknown action type: ${action['type']}');
    }
  }
}
