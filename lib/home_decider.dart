import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:security_app/components/Counselor/notifications.dart';
import 'package:security_app/services/state_notifier.dart';

import 'components/police officer/emergency_notification.dart';
import 'firebase_authentication/crud_service.dart';
import 'screens/splash_screen.dart';
import 'services/local_notification_services.dart';

class HomeDecider extends ConsumerStatefulWidget {
  const HomeDecider({super.key});

  @override
  ConsumerState<HomeDecider> createState() => _HomeDeciderState();
}

class _HomeDeciderState extends ConsumerState<HomeDecider> {
  Future<Widget> getInitialScreen() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SplashScreen();
    }

    // Update user's role in the notifier
    await ref.read(userRoleProvider.notifier).updateUserRole(user.uid);

    // Check the role from the provider
    final role = ref.read(userRoleProvider);

    if (role == 'police_officers') {
      return EmergencyNotifications(policeOfficerId: user.uid);
    } else if (role == 'counselors') {
      return CounselorNotificationsPage();
    } else {
      return const SplashScreen(); // Default to SplashScreen if role is not found
    }
  }

  @override
  void initState() {
    NotificationService.getDeviceToken(ref).then((token) {
      if (token != null) {
        // Save the token using the role from the provider
        final role = ref.read(userRoleProvider);
        if (role != null) {
          CRUDService.saveUserToken(role, token);
        }
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildWidgetFromSnapshot(snapshot),
        );
      },
    );
  }

  Widget _buildWidgetFromSnapshot(AsyncSnapshot<Widget> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox.shrink(); // Invisible placeholder during loading
    }
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading user data'));
    }
    if (snapshot.hasData) {
      return snapshot.data!;
    }
    return const SplashScreen(); // Default case
  }
}
