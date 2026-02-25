abstract class AdminRepository {
  Future<List<Map<String, dynamic>>> getPendingUsers();
  Future<void> validateUser(int id);
  Future<List<Map<String, dynamic>>> getPendingStocks();
  Future<void> validateStock(int id);
  Future<List<Map<String, dynamic>>> getPendingRoles();
  Future<void> validateRole(int id);
}
