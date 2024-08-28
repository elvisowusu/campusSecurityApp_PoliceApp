import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier to manage the user's role
class UserRoleNotifier extends StateNotifier<String?> {
  UserRoleNotifier() : super(null);

  // Method to update the user's role
  Future<void> updateUserRole(String uid) async {
    bool isPoliceOfficer = await _checkUserRole(uid, 'police_officers');
    bool isCounselor = await _checkUserRole(uid, 'counselors');

    if (isPoliceOfficer) {
      state = 'police_officers';
    } else if (isCounselor) {
      state = 'counselors';
    } else {
      state = null; // If role not found
    }
  }

  // Helper method to check user's role in Firestore
  Future<bool> _checkUserRole(String uid, String collection) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection(collection).doc(uid).get();
    return userDoc.exists;
  }
}

// Define a provider for the UserRoleNotifier
final userRoleProvider = StateNotifierProvider<UserRoleNotifier, String?>(
  (ref) => UserRoleNotifier(),
);
