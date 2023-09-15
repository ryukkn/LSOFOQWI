  import 'dart:convert';

import '../models/device.dart';
  import '../models/admin.dart';
  import '../models/faculty.dart';
  import '../models/laboratory.dart';
  import '../models/student.dart';
  import '../server/connection.dart';
  import 'package:http/http.dart' as server;

  Device decodeDevice(dynamic row){
    return Device(
      id: row['ID'],
      name: row['Name'],
      QR: row['QR'],
      labID: row['LabID']
    );
  }

  Student decodeStudent(dynamic row){
    return Student(
      id: row['ID'],
      fullname: row['fullname'],
      email: row['email'],
      contact: row['contact'],
      year: row['year'],
      block: row['block'],
      schedule: row['schedule'],
      QR: row['QR'],
    );
  }

  Faculty decodeFaculty(dynamic row){
    return Faculty(
        id: row['ID'],
        fullname: row['fullname'],
        email: row['email'],
        contact: row['contact'],
        department: row['department'],
        schedule: row['schedule'],
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
        building: row['Building'],
        room: row['Room'],
        units : row['units']
        );
  }

  Future<Student?> getStudent(String QR) async{
    var url = Uri.http(Connection.host,"flutter_php/getstudent.php");
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
    var url = Uri.http(Connection.host,"flutter_php/getdevice.php");
    var response = await server.post(url, body: {
      "QR": QR
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      print(data['message']);
      return null;
    }

    return decodeDevice(data['row']);
  }
 