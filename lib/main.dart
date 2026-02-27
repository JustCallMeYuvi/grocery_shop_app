import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grocery_shop_app/auth_screen.dart';
import 'package:grocery_shop_app/customer/customer_home_screen.dart';
import 'package:grocery_shop_app/customer/firebase_options.dart';
import 'package:grocery_shop_app/dash_board_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb || Platform.isWindows) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  print("🔔 Background Message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Always initialize like this for ALL platforms

  // ✅ Prevent duplicate app error
  // 🔥 SAFE INITIALIZATION FOR ALL PLATFORMS

  if (kIsWeb) {
    // 🌐 Web
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (Platform.isWindows) {
    // 🖥 Windows
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // 📱 Android / iOS
    await Firebase.initializeApp();
  }

  // if (kIsWeb) {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } else {
  //   await Firebase.initializeApp();

  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  //   await FirebaseMessaging.instance.requestPermission();
  //   const AndroidInitializationSettings androidSettings =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');

  //   const InitializationSettings initSettings =
  //       InitializationSettings(android: androidSettings);

  //   await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ✅ Only enable FCM for Android/iOS
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // ✅ Initialize local notifications (VERY IMPORTANT)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    // ✅ Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();
    print("🔥 DIRECT TOKEN FROM MAIN: $token");

    // ✅ ADD THIS 👇 (Foreground Listener)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'order_channel',
          'Order Notifications',
          channelDescription: 'Order status updates',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher', // ✅ REQUIRED
        );

        const NotificationDetails details =
            NotificationDetails(android: androidDetails);

        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          details,
        );
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': newToken}, SetOptions(merge: true));
      }
    });
  }
  // await FirebaseMessaging.instance.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const AuthScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          // 🔥 If document does not exist → create default customer
          FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'role': 'customer',
            'createdAt': Timestamp.now(),
          });

          return const CustomerHomeScreen();
        }

        final role = snapshot.data!.get('role');

        if (role == 'admin') {
          return const DashboardScreen();
        } else {
          return const CustomerHomeScreen();
        }
      },
    );
  }
}
