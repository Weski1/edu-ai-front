import '../services/auth_service.dart';

class AdminUtils {
  static Future<bool> isAdmin() async {
    final userData = await AuthService.getUserData();
    return userData != null && userData['role'] == 'admin';
  }
  
  static Future<Map<String, dynamic>?> getAdminData() async {
    final userData = await AuthService.getUserData();
    if (userData != null && userData['role'] == 'admin') {
      return userData;
    }
    return null;
  }
}
