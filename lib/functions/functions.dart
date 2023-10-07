  import 'dart:convert';

import 'package:bupolangui/models/course.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/models/schedule.dart';
import 'package:bupolangui/models/session.dart';
import 'package:intl/intl.dart';

import '../models/device.dart';
  import '../models/admin.dart';
  import '../models/faculty.dart';
  import '../models/laboratory.dart';
  import '../models/student.dart';
  import '../server/connection.dart';
  import 'package:http/http.dart' as server;

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
    remarks: row['Remarks']);
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
    return Report(id: row['ID'], 
    department: row['department'],
    laboratory: row['laboratory'],  
    faculty: row['fullname'], 
    course: row['course'], 
    yearblock: "$level-${row['block'].toString().replaceAll("Block ", "")}", 
    sessions: row['noOfSessions'],
    timeOut: row['TimeOut'], 
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


 