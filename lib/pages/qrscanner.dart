import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/student.dart';
import '../models/device.dart';
import '../functions/functions.dart';
import 'dart:io';


class QRScanner extends StatefulWidget {
  const QRScanner({super.key, required this.title});
  final String title;

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

  void setStudent(String QR) async{
    var student = await getStudent(QR);
    setState(() {
      this.student = student;      
    });
  }

   void setDevice(String QR) async{
    var device = await getDevice(QR);
    setState(() {
      this.device = device;      
    });
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
            setStudent(_studentID!);
          }
        }
      });
    });
  }

  
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
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
            child: (firstPhase()) ? QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(borderColor: Colors.blue, 
                borderWidth: 8.0,
                ),
              onQRViewCreated: deviceQR,
            ) : SizedBox(
              height: screenHeight * 0.25,width: screenHeight * 0.25,
              child: const DecoratedBox(decoration: BoxDecoration(
                color: Colors.blue,
              )),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text( (firstPhase() || device == null) ? "QR CODE SCANNING..." : device!.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0 * (screenHeight/900),
            ),
          ),
          (firstPhase()) ? SizedBox(height:  screenHeight * 0.07)
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
              child: (!firstPhase()) ? QRView(
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
          Text( (firstPhase()) ? "" : (!paired() || student == null) ? "QR CODE SCANNING..." :  student!.fullname,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0 * (screenHeight/900),
            ),
          ),
          (!paired()) ? SizedBox(height: screenHeight * 0.07,)
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
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}