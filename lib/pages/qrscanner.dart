import 'dart:convert';

import 'package:bupolangui/models/faculty.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/student.dart';
import '../models/device.dart';
import '../functions/functions.dart';
import 'dart:io';

import 'package:http/http.dart' as server;


class QRScanner extends StatefulWidget {
  final Faculty faculty;
  final Report? report;
  const QRScanner({super.key, required this.faculty, this.report});

  @override
  State<QRScanner> createState() => _QRScanner();
}

class _QRScanner extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? _deviceID;
  String? _studentID;
  
  Student? student;
  Device? device;

  QRViewController? controller;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  

  @override
  void reassemble() {
    super.reassemble();
    if(Platform.isAndroid){
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }


  bool firstPhase(){
      if(_deviceID !=  null || _deviceID == ''){
        if(_deviceID![0] == "d") {
          return false;
        } else {
          return true;
        }
      }
      return true;
  }

  bool paired(){
    if( (_studentID != null || _studentID == '') ){
      if( _studentID![0] == "s") {
        return true;
      }else{
        return false;
      }
    }
    return false;
  }

  Future setStudent(String QR) async{
    var student = await getStudent(QR);
    if(!mounted) return;
    if(student==null){
      setState(() {
      _studentID = null;      
    });
    }{
      setState(() {
      this.student = student;      
    });
    }
    
  }

  Future setDevice(String QR) async{
    var device = await getDevice(QR);
    if(!mounted) return;
    if(device==null){
      setState(() {
        _deviceID = null;
      });
    }else{
      setState(() {
        this.device = device;      
      });
    }
  }

  Future getLastSession (Report? report, String studentQR, String deviceQR) async{
    if(report == null) return null;
     var url = Uri.parse("${Connection.host}flutter_php/faculty_getlastsession.php");
      var response = await server.post(url, body: {
        'classID': report.id,
        'studentQR': studentQR, 
        'deviceQR': deviceQR,
      });
      var data= json.decode(response.body);
      if(!data['success']){
        print("Error.");
      }

      if(data['row'] != null ){
        return decodeSession(data['row']);
      }
      return null;
  }


  void deviceQR(QRViewController controller){
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if(firstPhase()){
          _deviceID = scanData.code;
        }else if(!paired()){
          if(device == null){
            setDevice(_deviceID!);
          }
          _studentID = scanData.code;
        }else{
          if(student == null){
            setStudent(_studentID!).then((value) {
               controller.pauseCamera().then((value) {
               getLastSession(widget.report, _studentID!, _deviceID!).then((lastSession) {
                if(lastSession != null){
                  Navigator.pushReplacement(
                              context,
                            PageRouteBuilder(
                                pageBuilder: (context , anim1, anim2) =>
                                    Evaluation(student: student!, device: device!,session: lastSession ,faculty: widget.faculty, screen: "Time In")));
                }else{
                  Navigator.pushReplacement(
                              context,
                            PageRouteBuilder(
                                pageBuilder: (context , anim1, anim2) =>
                                    Evaluation(student: student!, device: device!, faculty: widget.faculty, screen: "Time In")));
                }
               });
     
               }
               );
                
            }
            
            );
           
          }
        }
      });
    });
  }

  
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = MediaQuery.of(context).size.height/1000;
    return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.04),
              Text("PLEASE SCAN THE PC/LAPTOP'S QR CODE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0 * (screenHeight/900),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(height: screenHeight * 0.25,width: screenHeight * 0.25,
                child: (device == null) ? QRView(
                  key: qrKey,
                  overlay: QrScannerOverlayShape(borderColor: Colors.blue, 
                    borderWidth: 8.0,
                    ),
                  onQRViewCreated: deviceQR,
                ) : QrImageView(
                  data: device!.QR!,
                  version: QrVersions.auto,
                  size: screenHeight * 0.25,
                  ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text( (device == null) ? "QR CODE SCANNING..." : device!.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0 * (screenHeight/900),
                ),
              ),
              (device==null) ? SizedBox(height:  screenHeight * 0.07)
              :  Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    const Icon (Icons.check_circle, color: Colors.green,),
                    Text("SCAN SUCCESSFUL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0 * (screenHeight/900),
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text("PLEASE SCAN THE STUDENT'S QR CODE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0 * (screenHeight/900),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: SizedBox(height: screenHeight * 0.25,width: screenHeight * 0.25,
                  child: (device != null) ? QRView(
                  key: qrKey,
                    overlay: QrScannerOverlayShape(borderColor: Colors.blue, 
                      borderWidth: 8.0,
                      ),
                    onQRViewCreated: deviceQR,
                  ) :  SizedBox(
                    height: screenHeight * 0.25,width: screenHeight * 0.25,
                    child: const DecoratedBox(decoration: BoxDecoration(
                      color: Colors.blue,
                    )),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text( (device==null) ? "" : (student == null) ? "QR CODE SCANNING..." :  student!.fullname,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0 * (screenHeight/900),
                ),
              ),
              (student==null) ? SizedBox(height: screenHeight * 0.07,)
              : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    const Icon(Icons.check_circle, color: Colors.green,),
                    Text("SCAN SUCCESSFUL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0 * (screenHeight/900),
                        color: Colors.green
                      ),
                    ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(height: screenHeight * 0.04),
            ],
          );
      
  }

  @override
  void dispose() {
    if(controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }
}