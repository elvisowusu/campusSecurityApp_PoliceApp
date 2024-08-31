import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(minutes: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Police Patrol",
          content: "Monitoring danger zones",
        );
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    List<DangerZone> dangerZones = await getDangerZones();

    for (var zone in dangerZones) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance <= zone.radius) {
        await flutterLocalNotificationsPlugin.show(
          0,
          'Danger Zone Alert',
          'You are entering a danger zone',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'danger_zone_channel',
              'Danger Zone Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
        break;
      }
    }

    service.invoke('update');
  });
}

Future<List<DangerZone>> getDangerZones() async {
  final snapshot = await FirebaseFirestore.instance.collection('danger_zones').get();
  return snapshot.docs.map((doc) {
    return DangerZone(
      latitude: doc['latitude'],
      longitude: doc['longitude'],
      radius: doc['radius'],
    );
  }).toList();
}

class DangerZone {
  final double latitude;
  final double longitude;
  final double radius;

  DangerZone({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });
}