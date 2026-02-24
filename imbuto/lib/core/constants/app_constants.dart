class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://assma.amidev.bi/';
  static const String loginEndpoint = 'login/';
  static const String refreshEndpoint = 'refresh/';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  
  // User Types
  static const String multiplicatorType = 'multiplicateurs';
  static const String cultivatorType = 'cultivateurs';
  
  // Multiplicator Categories
  static const String preBasesCategory = 'Pré_Bases';
  static const String baseCategory = 'Base';
  static const String certifiedCategory = 'Certifiés';
  
  // App Info
  static const String appName = 'Imbuto';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
}
