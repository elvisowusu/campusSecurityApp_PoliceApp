import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const _policeOfficerIdKey = 'policeOfficerId';

  // Save policeOfficerId to SharedPreferences
  static Future<void> savePoliceOfficerId(String policeOfficerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_policeOfficerIdKey, policeOfficerId);
  }

  // Retrieve policeOfficerId from SharedPreferences
  static Future<String?> getPoliceOfficerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_policeOfficerIdKey);
  }

  // Clear the stored policeOfficerId (for sign out)
  static Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_policeOfficerIdKey);
  }
}
