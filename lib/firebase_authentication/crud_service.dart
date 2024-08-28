import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CRUDService {
  static User? user = FirebaseAuth.instance.currentUser;

  // Save FCM token to Firestore with the role as a parameter
  static Future saveUserToken(String role, String token) async {
    if (user == null) return;

    Map<String, dynamic> data = {
      "email": user!.email,
      "token": token,
    };
    try {
      await FirebaseFirestore.instance
          .collection(role) // Use role from parameter
          .doc(user!.uid)
          .set(data);

      print('added token');
    } catch (e) {
      print('error in saving to firestore');
      print(e.toString());
    }
  }
}
