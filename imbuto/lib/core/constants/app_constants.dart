class AppConstants {
  static const String appName = 'Imbuto';
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  
  // User types
  static const List<String> userTypes = ['multiplicateurs', 'cultivateurs'];
  static const String cultivatorType = 'cultivateurs';
  static const String multiplicatorType = 'multiplicateurs';
  
  // Multiplicator types
  static const List<String> multiplicatorTypes = ['Pré_Bases', 'Base', 'Certifiés'];
  static const String preBasesCategory = 'Pré_Bases';
  static const String baseCategory = 'Base';
  static const String certifiedCategory = 'Certifiés';
  
  // Validation constants
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 8;
  
  // Provinces in Burundi
  static const List<String> provinces = [
    'Bubanza', 'Bujumbura Mairie', 'Bujumbura Rural', 'Bururi',
    'Cankuzo', 'Cibitoke', 'Gitega', 'Karuzi', 'Kayanza',
    'Kirundo', 'Makamba', 'Muramvya', 'Muyinga', 'Mwaro',
    'Ngozi', 'Rumonge', 'Rutana', 'Ruyigi'
  ];
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
}
