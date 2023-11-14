
import 'package:bupolangui/firebase_options.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Notification
import 'package:flutter_local_notifications/flutter_local_notifications.dart'as notif ;

 FirebaseMessaging messaging = FirebaseMessaging.instance ;

var  flutterLocalNotificationsPlugin ;


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); 
  if(!(kIsWeb && defaultTargetPlatform==TargetPlatform.android)){
    messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
    );
  }
  if(!kIsWeb){
    flutterLocalNotificationsPlugin = notif.FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = const notif.AndroidInitializationSettings('@mipmap/logo');
  
    var initializationSettings = notif.InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<notif.AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSD ComLab Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const LandingPage()
    );
  }
}
