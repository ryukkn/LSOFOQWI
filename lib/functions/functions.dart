  import 'dart:convert';
import 'dart:typed_data';

import 'package:bupolangui/models/course.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/models/schedule.dart';
import 'package:bupolangui/models/session.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/device.dart';
import '../models/admin.dart';
import '../models/faculty.dart';
import '../models/laboratory.dart';
import '../models/student.dart';
import '../server/connection.dart';
import 'package:http/http.dart' as server;
import 'package:bupolangui/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
  // Notification

  Device decodeDevice(dynamic row){
    return Device(
      id: row['ID'],
      name: row['Name'],
      QR: row['QR'],
      labID: row['LabID'],
    );
  }
  
  Session decodeSession(dynamic row){
    return Session(id: row['ID'], timestamp: row['Timestamp'], 
    student: row['fullname'], device: row['Name'], 
    studentQR: row['student_qr'], deviceQR: row['device_qr'],
    systemUnit: row['SystemUnit'], monitor: row['Monitor'], 
    keyboard: row['Keyboard'], mouse: row['Mouse'], 
    avrups: row['AVRUPS'], wifidongle: row['WIFIDONGLE'], 
    remarks: row['Remarks'],
    lastSeen: row['laboratory']
    );
  }

  Report decodeReport(dynamic row){
    String level = '';
    switch(row['level']){
      case 'First Year':
        level = "1";
        break;
      case 'Second Year':
        level = "2";
        break;
      case 'Third Year':
        level = "3";
        break;
      case 'Fourth Year':
        level = "4";
        break;
      case 'Fifth Year':
        level = "5";
        break;
    }
    Uint8List? eSign;
    if(row['ESign']!=null){
      eSign = Uint8List.fromList(List<int>.from(json.decode(row['ESign'])));
    }
    
    return Report(id: row['ID'], 
    department: row['department'],
    laboratory: row['laboratory'],  
    faculty: row['fullname'], 
    course: row['course'], 
    yearblock: "$level-${row['block'].toString().replaceAll("Block ", "")}", 
    sessions: row['noOfSessions'],
    timeOut: row['TimeOut'],
    eSign: eSign, 
    timeIn: row['TimeIn']);
  }

  Student decodeStudent(dynamic row){
    return Student(
      id: row['ID'],
      fullname: row['fullname'],
      email: row['email'],
      contact: row['contact'],
      block: row['BlockID'],
      QR: row['QR'],
      profile: row['profile'],
    );
  }

  Schedule decodeSchedule(dynamic row){
    return Schedule(id: row['ID'], 
    course: row['course'], 
    laboratory: parseAcronym(row['laboratory']),
    labID : row['LabID'],
    level: row['level'], 
    block: row['block'], 
    blockID: row['BlockID'],
    day: row['day'], 
    time: row['time'],);
  }

  Faculty decodeFaculty(dynamic row){
    return Faculty(
        id: row['ID'],
        fullname: row['fullname'],
        email: row['email'],
        contact: row['contact'],
        department: row['department'],
        profile:  row['profile'],
    );
  }

  Admin decodeAdmin(dynamic row){
    return Admin(
      id: row['ID'],
      email: row['email'],
      fullname: row['fullname'],
      contact: row['contact'],
    );
  }

  Laboratory decodeLaboratory(dynamic row){
    return Laboratory(
        id: row['ID'],
        department: row['department'],
        laboratory: row['laboratory'],
        units : row['units']
        );
  }

  Future<Student?> getStudent(String QR) async{
    var url = Uri.parse("${Connection.host}flutter_php/getstudent.php");
    var response = await server.post(url, body: {
      "QR": QR
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      print(data['message']);
      return null;
    }

    return decodeStudent(data['row']);
  }

  Future<Device?> getDevice(String QR) async{
    var url = Uri.parse("${Connection.host}flutter_php/getdevice.php");
    var response = await server.post(url, body: {
      "QR": QR
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      return null;
    }
  
    return decodeDevice(data['row']);
  }

String parseDay(String timestamp){
  var datetime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestamp);
  return DateFormat('EEEE').format(datetime);
}

String parseDate(String timestamp){
  var datetime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestamp);
  return DateFormat('MMMM d, yyyy').format(datetime);
}
String parseTime(String timestamp){
  var datetime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestamp);
  return DateFormat('hh:mm a').format(datetime);
}

String parseAcronym(String text){
  String acronym = "";
  for(int i = 0; i < text.length; i++){
    if(text.codeUnitAt(i)<97 && text.codeUnitAt(i)!=32){
      acronym+=text[i];
    }
  }
  return acronym;
}

Course decodeCourse(dynamic row){
    return Course(id: row['ID'], course: row['course'], year: row['level'], block: row['block'], levelID: row['levelID'],courseID: row['courseID']);
}


 String getShortCourse(Schedule schedule){
    var level = "";
    switch(schedule.level){
          case "First Year":
            level = "1";
            break;
          case "Second Year":
            level = "2";
            break;
          case "Third Year":
            level = "3";
            break;
          case "Fourth Year":
            level = "4";
            break;
          case "Fifth Year":
            level = "5";
            break;
        }
    return "${parseAcronym(schedule.course)} $level-${schedule.block.toString().split(" ")[1]}";
  }

// Notifications
  void scheduleAlarm(Schedule schedule,{int offset = 0}) async {
 
    List<String> weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY","FRIDAY", "SATURDAY"];

     AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'Ongoing Class',
      'Ongoing Class',
      importance: Importance.max  ,
      showBadge: true ,
      playSound: true,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString() ,
      channelDescription: 'Channel for Alarm notification',
      importance: Importance.high,
      priority: Priority.high ,
      playSound: true,
      // icon: '@mipmap/logo',
    );
    var currentday = DateFormat("yyyy-MM-dd HH:mm:ss").parse(tz.TZDateTime.from(DateTime.now(), tz.getLocation("Asia/Manila")).toString());
    var currentweekday = weekdays.indexOf(parseDay(tz.TZDateTime.from(DateTime.now(), tz.getLocation("Asia/Manila")).toString()).toUpperCase())+1;
    var targetweekday = int.parse(schedule.day)+1;
    var days = ((targetweekday - currentweekday) + 7) % 7 ;

    var targetTime = DateFormat("hh:mm a").parse(schedule.time.split(" - ")[0]);
    
    int seconds = ((targetTime.hour * 60 * 60) + targetTime.minute *60 + targetTime.second)
      - ((currentday.hour * 60 * 60) + currentday.minute *60 + currentday.second)
    ;
    if(seconds < 0){
      seconds += 86400;
    }
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
      await flutterLocalNotificationsPlugin.zonedSchedule(offset + int.parse(schedule.id), "You have a class in ${getShortCourse(schedule)} (${schedule.laboratory})", schedule.time, tz.TZDateTime.now(tz.local).add(
        Duration(days: days, seconds: seconds)),
         platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  
  }

  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString() ,
      importance: Importance.max  ,
      showBadge: true ,
      playSound: true,
    );

     AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString() ,
      channelDescription: 'Verification Notification',
      importance: Importance.high,
      priority: Priority.high ,
      playSound: true,
    //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
    //  icon: largeIconPath
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true ,
      presentBadge: true ,
      presentSound: true
    ) ;

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero , (){
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails ,
      );
    });

  }

  Future<String> initializeFirebaseNotifications() async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);      
    });
    String? token = await messaging.getToken();
    return token!;
  }

  
  Map<String, Object> composeMessage({required String receiver,required  String title,required  String body}){
    var data = {
        'to' : receiver,
        'notification' : {
          'title' : title ,
          'body' : body ,
      },
        // 'android': {
        //   'notification': {
        //     'notification_count': 23,
        //   },
        // },
        // 'data' : {
        //   'type' : 'msj' ,
        //   'id' : 'Asif Taj'
        // }
      };
    return data;
  }



 