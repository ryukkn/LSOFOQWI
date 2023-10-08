
import 'package:bupolangui/firebase_options.dart';
import 'package:bupolangui/models/faculty.dart';
import 'package:bupolangui/pages/admin_dashboard.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:bupolangui/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// Notification
import 'package:flutter_local_notifications/flutter_local_notifications.dart'as notif ;
var  flutterLocalNotificationsPlugin ;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb){
    flutterLocalNotificationsPlugin = notif.FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = notif.AndroidInitializationSettings('@mipmap/ic_launcher');
  
    var initializationSettings = notif.InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<notif.AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
      title: 'BUPC Computer Laboratory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const LandingPage()
    );
  }
}
