
import 'dart:async';
import 'dart:convert';

import 'package:bupolangui/components/custombuttons.dart';
import 'package:bupolangui/components/popups.dart';
import 'package:bupolangui/constants/constants.dart';
import 'package:bupolangui/models/course.dart';
import 'package:bupolangui/models/device.dart';
import 'package:bupolangui/models/faculty.dart';
import 'package:bupolangui/models/laboratory.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/models/session.dart';
import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/models/verification.dart';
import 'package:bupolangui/printables/qrs.dart';
import 'package:bupolangui/printables/records.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as server;
import 'package:printing/printing.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bupolangui/main.dart';

// ignore: must_be_immutable
class DashboardContent extends StatefulWidget {
  DashboardContent({super.key, required this.content, required this.checkPending});
  int content;
  final Function checkPending;

  @override
  State<DashboardContent> createState() => _DashboardContent();
}


class _DashboardContent extends State<DashboardContent> {
  List<Laboratory> laboratories = [

  ] ;

  List<String> accountTypes = [
    "Admins", "Faculties", "Students"
  ];
  List<Student> students = [];

  List<Device> devices =[

  ];

  int callOnce = 0;

  TextEditingController department = TextEditingController();
  TextEditingController laboratory = TextEditingController();
  TextEditingController prefix = TextEditingController();
  TextEditingController startIndex = TextEditingController();
  TextEditingController noOfDevices = TextEditingController();

  TextEditingController searchDevice = TextEditingController();
  TextEditingController searchAccount = TextEditingController();

  TextEditingController email = TextEditingController();
  TextEditingController fullname = TextEditingController();
  TextEditingController contact = TextEditingController();
    TextEditingController password = TextEditingController();
    List<TextEditingController> courseController = 
    [TextEditingController(),TextEditingController(),TextEditingController(),TextEditingController(),TextEditingController(),TextEditingController()];

  // WebSocketChannel? channel;
  String? errorMessage;

  final _streamController = StreamController.broadcast();

  int _activeLab = 0;
  int _activeCategory = 0;

  String moveID = "";

  bool viewDefectives = false;
  bool _hasDefective = false;

  List<Report> _reports = [];
  List<Course> _courses = [];
  List<Verification> subjects = [];

  Timer? timer;

  var accounts = [];

  bool loadingDevices = false;

  void openLab (int selected) async{
    bool hasDefective = false;
    setState(() {
      loadingDevices = true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/admin_openLab.php");
    var response = await server.post(url, body: {
      "LabID" : laboratories[selected-1].id
    });
    var data = json.decode(response.body);

    if(data['success']){
      var rows = data['rows'];
      List<Device> loadedDevices = [];
      rows.forEach((dynamic row){
        var newDevice =decodeDevice(row);
        if(row['session'] != null){
          newDevice.lastSession = Session(
            id: row['session']['ID'],
            student: row['session']['fullname'],
            device: row['session']['Name'],
            timestamp: row['session']['Timestamp'],
            lastSeen: row['session']['laboratory']
          );
          newDevice.systemUnit = row['session']['SystemUnit'];
          newDevice.monitor = row['session']['Monitor'];
          newDevice.mouse = row['session']['Mouse'];
          newDevice.keyboard = row['session']['Keyboard'];
          newDevice.avrups = row['session']['AVRUPS'];         
          newDevice.wifidongle = row['session']['WIFIDONGLE'];
          newDevice.remarks = row['session']['Remarks'];
          if(newDevice.isDefective()){
            hasDefective = true;
          }
        }
      
        loadedDevices.add(newDevice);
      });
      setState(() { 
        devices = loadedDevices;
        _activeLab = selected;
        _hasDefective = hasDefective;
        loadingDevices = false;
      });
    }else{
      print(data['message']);
    }

  }


  void createLab() async{
    var url = Uri.parse("${Connection.host}flutter_php/admin_createlab.php");
    var response = await server.post(url, body: {
      "department": department.text,
      "laboratory": laboratory.text,
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      print(data['message']);
    }else{
      loadLabs();
    }
  }

  bool loadingClassSessions=  false;

  Future loadClassSessions() async{
    setState((){
      loadingClassSessions=true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/admin_getclasssessions.php");
    var response = await server.post(url, body: {
    });
    var data= json.decode(response.body);
    if(!data['success']){
      print(data['message']);
    }else{
      var rows = data['rows'];
      List<Report> reports = [];
      rows.forEach((dynamic row)=>{
        reports.add(decodeReport(row))
      });
      if(mounted){
        setState(() {
          _reports = reports;
          loadingClassSessions = false;
        });
      }
    }
  }
  bool loadingCourses = false;
   Future loadCourses() async{
    setState(() {
      loadingCourses = true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/admin_loadcourses.php");
    var response = await server.post(url, body: {
    });
    var data= json.decode(response.body);
    if(!data['success']){
      print(data['message']);
    }else{
      var rows = data['rows'];
      List<Course> courses = [];
      rows.forEach((dynamic row)=>{
        courses.add(decodeCourse(row))
      });
      if(mounted){
        setState(() {
          _courses = courses;
          loadingCourses = false;
        });
      }
    }
  }

  bool loadingLabs  =false;

  void loadLabs() async{
    setState(() {
      loadingLabs = true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/getLabs.php");
    var response = await server.get(url);
    var data = json.decode(response.body);
    if(data['success']){
      var rows = data['rows'];
      List<Laboratory> loadedLabs = [];
      rows.forEach((dynamic row) => {
      loadedLabs.add(decodeLaboratory(row))
      });
      if(mounted){
        setState(() {
          laboratories = loadedLabs;
          loadingLabs = false;
        });
      }
      if(_activeLab != 0){
        openLab(_activeLab);
      }else{
        setState(() {
          devices = [];
        });
      }
    }else{
      print(data['message']);
    }
      
  }

  Future getLab(String id) async{
    var url = Uri.parse("${Connection.host}flutter_php/getlab.php");
    var response = await server.post(url, body: {
      "id": id,
    });

    var data = json.decode(response.body);

    return decodeLaboratory(data['row']);
  }

  void changeLabName(String id) async{

    var url = Uri.parse("${Connection.host}flutter_php/admin_changelabname.php");
    var response = await server.post(url, body: {
      "id": id,
      "department": department.text,
      "laboratory": laboratory.text
    });
    var data = json.decode(response.body);

    if(data['success']){
      loadLabs();
      setState(() {
        _activeLab = 0;
      });
    }else{
      print(data['message']);
    }

  }
  void editAccount(String id, String type) async{
    var url = Uri.parse("${Connection.host}flutter_php/editaccount.php");
    var response = await server.post(url, body: {
      "id": id,
      "type": type,
      "email": email.text,
      "fullname": fullname.text,
      "contact" : contact.text,
      "password": password.text,
    });
    var data = json.decode(response.body);

    if(data['success']){
      loadAccounts();
    }else{
      print(data['message']);
    }

  }

  void delete(String id , String from) async{
    var url = Uri.parse("${Connection.host}flutter_php/delete.php");
    var response = await server.post(url, body: {
      "id": id,
      "from": from
    });
    var data = json.decode(response.body);
    
    if(data['success']){
      if(from == "laboratories"){
        setState(() {
          _activeLab = 0;
        });
        loadLabs();
      }
      if(from == "devices"){
        openLab(_activeLab);
      }
      if(from=="faculty" || from == "students"){
        loadAccounts();
      }
      if(from=="courses"){
        loadCourses();
      }
      if(from =='class_sessions'){
        loadClassSessions();
      }
    }else{
      print(data['message']);
    }
  }

  void createDevices() async {
    var url = Uri.parse("${Connection.host}flutter_php/admin_createdevices.php");
    var response = await server.post(url, body: {
      "prefix": prefix.text,
      "startIndex": startIndex.text,
      "noOfDevices": noOfDevices.text,
      "labID": laboratories[_activeLab-1].id,
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      print(data['message']);
    }else{
      openLab(_activeLab);  
    }
  }

  void setActive(int selected){
    setState(() {
      _activeCategory = selected;
    });
  }

  bool loadingAccounts = false;
  void loadAccounts () async{
    setState(() {
      loadingAccounts = true;
    });
    if(_activeCategory == 0) return;
    var url = Uri.parse("${Connection.host}flutter_php/admin_accounts.php");
    var response = await server.post(url, body: {
      "type" : _activeCategory.toString(),
    });
    var data = json.decode(response.body);

    if(data['success']){
      var rows = data['rows'];
      var loadedAccounts = [];
      switch(_activeCategory){
        case 1:
          rows.forEach((dynamic row) => {
          loadedAccounts.add(decodeAdmin(row))
        });
        break;
         case 2:
          rows.forEach((dynamic row) => {
          loadedAccounts.add(decodeFaculty(row))
        });
        break;
         case 3:
          rows.forEach((dynamic row) => {
          loadedAccounts.add(decodeStudent(row))
        });
        break;
      }
      setState(() {
        accounts = loadedAccounts;
        loadingAccounts = false;
      });
    }else{
      print(data['message']);
    }

  }

  Future moveDevice(Device device) async{
    var url = Uri.parse("${Connection.host}flutter_php/admin_movedevice.php");
    var response = await server.post(url, body: {
      "id" : device.id,
      "labID" : moveID,
    });
    var data = json.decode(response.body);
    if(data['success']){
      loadLabs();
      openLab(_activeLab);
    }else{
      print(data['message']);
    }
  }

  void verify(Verification verification)async{
    
    // var url = Uri.parse(Connection.host+"flutter_php/admin_deleterequest.php");
    //   var response = await server.post(url, body: {
    //     'id' : verification.id,
    // });
    // var data = json.decode(response.body);
     var url = Uri.parse("${Connection.host}flutter_php/signup.php");
     var response = await server.post(url, body: {
      "pendingID" : verification.id,
      "fullname": verification.fullname,
      "email": verification.email,
      "contact": verification.contact,
      "password": verification.password,
      "priviledge": verification.accountType,
      "devicetoken": verification.deviceToken,
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print("error");
    }else{
      var message = composeMessage(receiver: verification.deviceToken, title: "Sign up was VERIFIED!", body: "You can now login using your credentials.");
      await server.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(message) ,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization' : 'key=AAAAKtkW_mU:APA91bHCp3TSoHw1jo5lDh7ZtkxYVLnCZyagNx9KmjU0bhky0zgIJaAKsdKcWl49McArPbpKjKjQec0NHau2m_LIhF_r9HPkiHieZU7DinKYJRgBMVbVAAUI5PAp5gmTVCwLpZ9yImcV'
          }
        );
      refresh();
    }
    // WEBSOCKET IMPLEMENTATION
    // channel!.sink.add(
    //   json.encode({
    //     "type" : "verify",
    //     "id" : id
    //   })
    // );
  }

  void reject(Verification verification) async{
    var url = Uri.parse("${Connection.host}flutter_php/delete.php");
      var response = await server.post(url, body: {
        'id' : verification.id,
        'from': 'pending'
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print("error");
    }else{
      var message = composeMessage(receiver: verification.deviceToken, title: "Sign up was REJECTED!", body: "Please sign up again with proper credentials.");
      await server.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(message) ,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization' : 'key=AAAAKtkW_mU:APA91bHCp3TSoHw1jo5lDh7ZtkxYVLnCZyagNx9KmjU0bhky0zgIJaAKsdKcWl49McArPbpKjKjQec0NHau2m_LIhF_r9HPkiHieZU7DinKYJRgBMVbVAAUI5PAp5gmTVCwLpZ9yImcV'
          }
        );
      refresh();
    }

    // WEBSOCKET IMPLEMENTATION
    // channel!.sink.add(
    //   json.encode({
    //     "type" : "reject",
    //     "id" : id
    //   })
    // );
  }
   void deleteAllRequests(int priviledge) async{
     var url = Uri.parse("${Connection.host}flutter_php/admin_deleteallrequests.php");
      var response = await server.post(url, body: {
        'priv' : priviledge.toString(),
    });

    var data = json.decode(response.body);
    if(!data['success']){
      print("error");
    }else{
       subjects.forEach((rejectedAccounts)async{
       var message = composeMessage(receiver: rejectedAccounts.deviceToken, title: "Sign up was REJECTED!", body: "Please sign up again with proper credentials.");
       await server.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(message) ,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization' : 'key=AAAAKtkW_mU:APA91bHCp3TSoHw1jo5lDh7ZtkxYVLnCZyagNx9KmjU0bhky0zgIJaAKsdKcWl49McArPbpKjKjQec0NHau2m_LIhF_r9HPkiHieZU7DinKYJRgBMVbVAAUI5PAp5gmTVCwLpZ9yImcV'
          }
        );
      });
      refresh();
    }

    // WEBSOCKET IMPLEMENTATION
    // channel!.sink.add(
    //   json.encode({
    //     "type" : "deleteallrequests",
    //     "category" : priviledge.toString(),
    //   })
    // );
  }

   void acceptAllRequests(int priviledge) async{
     var url = Uri.parse("${Connection.host}flutter_php/admin_acceptallrequests.php");
      var response = await server.post(url, body: {
        'priv' : priviledge.toString(),
    });
    var data = json.decode(response.body);
  
    if(!data['success']){
      print("error");
    }else{
      subjects.forEach((verifiedAccounts)async{
       var message = composeMessage(receiver: verifiedAccounts.deviceToken, title: "Sign up was VERIFIED!", body: "You can now login using your credentials.");
       await server.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(message) ,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization' : 'key=AAAAKtkW_mU:APA91bHCp3TSoHw1jo5lDh7ZtkxYVLnCZyagNx9KmjU0bhky0zgIJaAKsdKcWl49McArPbpKjKjQec0NHau2m_LIhF_r9HPkiHieZU7DinKYJRgBMVbVAAUI5PAp5gmTVCwLpZ9yImcV'
          }
        );
      });
      refresh();
    }

  }

  bool facultyHasPending = false;
  bool studentHasPending = false;

  bool verificationUpdate = false;
  void refresh() async{
    setState((){
      verificationUpdate = true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/getpending.php");
    var response = await server.post(url, body: {
    });

    var data = json.decode(response.body);

    if(data['success']){
      facultyHasPending = false;
      studentHasPending = false;
      if(data['rows'].length > 0){
        data['rows'].forEach((dynamic row){
        if(row['account'].toString() == "1"){
            facultyHasPending = true;
          }
          if(row['account'].toString() == "2"){
            studentHasPending = true;
          }
        });
      }
      _streamController.add(data['rows']);
      setState((){
        verificationUpdate = false;
      });
      widget.checkPending();
    }

    // WEBSOCKET IMPLEMENTATION
    // if(channel != null){
    //   channel!.sink.close();
    // }
    // channel = WebSocketChannel.connect(
    //     Uri.parse(Connection.socket), 
    // );
    // try{
    // await channel!.ready;
    //   setState(() {
    //     errorMessage = null;
    //   });
    // }catch(e){
    //   setState(() {
    //     errorMessage = "Unable to connect  to the server.";
    //   });
    //   return;
    // }
    // _streamController.addStream(channel!.stream);
    // channel!.sink.add(
    //   json.encode({
    //     "type" : "getrequests",
    //   })
    // );
  }

  Future<List<Session>> loadSessionHistory(device) async{
    List<Session> sessions = [];
    var url = Uri.parse("${Connection.host}flutter_php/admin_getsessions.php");
    var response = await server.post(url, body: {
      "id": device.id,
    }); 
    var data = json.decode(response.body);
    if(!data['success']){
      print("Error");
    }else{
      var rows = data['rows'];
      rows.forEach((row)=>{
        sessions.add(decodeSession(row))
      });
    }
    return sessions;
  }
  
  
  @override
  void initState() {
    super.initState();
    department.text = "Computer Studies Department";
     messaging.getToken(vapidKey: "BH7AbxiovqSDt8-gqLkvKCPIWYdZAjpTOAwASl3h4mzNZcYlS1Hrm1g2Zq50Sm8anuryxfm3vRTTl17pnIcUPqs").then((value){
       var url = Uri.parse("${Connection.host}flutter_php/admin_settoken.php");
        server.post(url, body: {
          "token": value,
        });
    });
    FirebaseMessaging.onMessage.listen((message) {
      refresh();
    });
    // timer = Timer.periodic(Duration(seconds: 1), (timer) { 
    //   refresh();
    //   loadCourses();
    //   loadClassSessions();
    //   loadLabs();
    //   loadAccounts();
    //   if(_activeLab != 0){
    //     openLab(_activeLab);
    //   }
    // });
  }

  @override
  void dispose(){
    super.dispose();
    timer?.cancel();
    // if(channel!=null){
    //   channel!.sink.close();
    // }
    department.dispose();
    laboratory.dispose();
    prefix.dispose();
    startIndex.dispose();
    noOfDevices.dispose();
    email.dispose();
    password.dispose();
    contact.dispose();
    fullname.dispose();
    searchAccount.dispose();
    searchDevice.dispose();
    for (var controller in courseController) {
      controller.dispose();
    }
    _streamController.close();
  }


  Future deleteCourse(String? courseID) async{
    var url = Uri.parse("${Connection.host}flutter_php/delete.php");
    var response = await server.post(url, body: {
      "id": (courseID == null)? null: courseID,
      "from": 'courses'
    });
    var data= json.decode(response.body);
    if(!data['success']){
      print("Error");
    }else{
      loadCourses();
    }
  }

  Future addCourse() async{
    var url = Uri.parse("${Connection.host}flutter_php/admin_addcourse.php");
    var response = await server.post(url, body: {
      "course": courseController[0].text,
      "firstYear": courseController[1].text,
      "secondYear": courseController[2].text,
      "thirdYear": courseController[3].text,
      "fourthYear": courseController[4].text,
      "fifthYear": courseController[5].text,
    });
    var data= json.decode(response.body);
    if(!data['success']){
      print("Error");
    }else{
      loadCourses();
    }
  }
  List<String> columns =  ["Laboratory", "Faculty", "Course Code", "Class", "Date" ,  "Time In", "TIme Out", "Action"];

  List<String> courseColumns = ["No.", "Course", "Year Levels", "Action"];
  
  List<DataColumn> getColumns(List<String> columns){
    return columns.map((String column) => DataColumn(
      label: Flexible(child: Text(column)),
    )).toList();
  }

  List<DataRow> getReports(){
    return _reports.map((Report report) => DataRow(
      onLongPress: (){
        showDialog(context: context, builder: (context)=>AlertDialog(
          title: const Text( "Are you sure you want to delete this report?"),
          actions: [
            TextButton(child: const Text("Yes"), onPressed:(){
              delete(report.id, 'class_sessions');
              Navigator.of(context).pop();
            }),
            TextButton(child: const Text("No"), onPressed:(){
              Navigator.of(context).pop();
            }),
          ]
        ));
      },
      cells: [
        DataCell(Text(parseAcronym(report.laboratory))),
        DataCell(Text(report.faculty)),
        DataCell(Text(parseAcronym(report.course))),
        DataCell(Text(report.yearblock)),
        DataCell(Text(parseDate(report.timeIn))),
        DataCell(Text(parseTime(report.timeIn))),
        DataCell(Text(parseTime(report.timeOut!))),
        DataCell(TextButton(onPressed: (){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds:500),
              content: Text('Printing Report')),
          );
          printReport(report);
        },child: const Icon(Icons.print_outlined,))),
      ]
    )).toList();
  }

  List<DataRow> getCourses(scaleFactor){
    List<DataRow> rows = [];
    int i = 0;
    if(_courses.isEmpty) return rows;
    Course lastCourse = _courses[0];
    String lastLevel = "";
    String levelSet = "";
    for(int k = 0; k < _courses.length+1; k++){
      if(k < _courses.length){
        var course = _courses[k];
        if(course.courseID!=lastCourse.courseID){
          // lastCourse = course;
          // String levelSet = "";
          // switch(noOfLevels){
          //   case 1:
          //     levelSet = "1st Year";
          //     break;
          //   case 2:
          //     levelSet = "1st , 2nd  Year";
          //     break;
          //   case 3:
          //     levelSet = "1st , 2nd , 3rd Year";
          //     break;
          //   case 4:
          //     levelSet = "1st , 2nd, 3rd , 4th Year";
          //     break;
          //   case 5:
          //     levelSet = "1st , 2nd, 3rd , 4th , 5th Year";
          //     break;
          // }
        Course selectedCourse = lastCourse;
        rows.add(DataRow(
              cells: [
              DataCell(Container(child: Text((i+1).toString()))),
              DataCell(Container(child: Text("${selectedCourse.course} (${parseAcronym(selectedCourse.course)})"))),
              DataCell(Container(child: Text(levelSet))),
              DataCell(TextButton(onPressed: (){
                showDialog(context:context, builder: (context)=>manageCourse(1,_courses, selectedCourse, courseController,  (){
                }, ()=>{
                  deleteCourse(selectedCourse.courseID)
                }),
              
                );
              },child: const Icon(Icons.info,))),
            ]
            ));
          lastCourse = course;
          levelSet = "";
          i++;
        }
        if(lastLevel != course.levelID){
          String yearText =course.year;
          if(levelSet == ""){
            levelSet = yearText;
          }else{
            levelSet = "$levelSet, $yearText";
          }
          lastLevel = course.levelID!;
        }
      }else{
        Course selectedCourse = lastCourse;
        rows.add(DataRow(
              cells: [
              DataCell(Container(child: Text((i+1).toString()))),
              DataCell(Container(child: Text("${selectedCourse.course} (${parseAcronym(selectedCourse.course)})"))),
              DataCell(Container(child: Text(levelSet))),
              DataCell(TextButton(onPressed: ()=>{
                showDialog(context:context, builder: (context)=>manageCourse(1,_courses, selectedCourse, courseController,  (){
                }, ()=>{
                  deleteCourse(selectedCourse.courseID)
                }),
              
                )
              },child: const Icon(Icons.info,))),
            ]
            ));
      }

  
    }
    return rows;
  }

  Future printReport(Report report) async{
    var url = Uri.parse("${Connection.host}flutter_php/admin_openclasssession.php");
      var response = await server.post(url, body: {
        "id" : report.id,
      });

  
  var data = json.decode(response.body);
  if(data['success']){
    final image = await imageFromAssetBundle("/images/bupolanguisealnocolor.png");
    final materialIcons = await rootBundle.load("assets/fonts/materialIcons.ttf");
    final materialIconsTtf = pw.Font.ttf(materialIcons);
    // parse classsession, max 15
    List<List<Session>> sessions = [];
    var rows = data['rows'];
    int i = 0;
    int currentNoOfSessions = 0;
    sessions.add([]);
    rows.forEach((dynamic row){
      if(currentNoOfSessions >= 15){
        i+=1;
        sessions.add([]);
        currentNoOfSessions=0;
      }
      sessions[i].add(decodeSession(row));
      currentNoOfSessions +=1;
    });
    final doc = pw.Document();
       for(int k = 0; k<sessions.length; k++){
         doc.addPage(pw.Page(
            pageTheme: pw.PageTheme(
              theme:pw.ThemeData.withFont(icons: materialIconsTtf),
               pageFormat: PdfPageFormat.a4.landscape.copyWith(marginBottom: 0, marginTop: 0, marginRight: 0, marginLeft: 0),
            ),
              build: (pw.Context context) {
                return buildPrintableReport(sessions[k], report , image, 15*k);
              })); // Page
       }
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save()
        );
  }
   
  }


  Future printQRs()async{

    List<List<Device>> deviceQrs= [];
    int i = 0;
    int noOfQR = 0;
    deviceQrs.add([]);
  
    for (var device in devices) {
      if(noOfQR >= 6){
        deviceQrs.add([]);
        i+=1;
        noOfQR = 0;
      }
      deviceQrs[i].add(device);
      noOfQR+=1;
    }

 
    final doc = pw.Document();
       for(int k = 0; k<deviceQrs.length; k++){
         doc.addPage(pw.Page(
            pageTheme: pw.PageTheme(
               pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 0, marginTop: 0, marginRight: 0, marginLeft: 0),
            ),
              build: (pw.Context context) {
                return buildPrintableQR(deviceQrs[k]);
              })); // Page
       }
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save()
        );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =MediaQuery.of(context).size.width;
    double  scaleFactor = MediaQuery.of(context).size.height / 1000;
    // ignore: unused_local_variable
    Color primaryColor  = const Color.fromARGB(238, 7, 81, 110);
    switch(widget.content){
      case 1:
      if(callOnce != widget.content){
                setState((){
                  devices = [];
                });
                loadLabs();
                searchDevice.text = "";
                callOnce = widget.content;
        }
        return Column(
        children: [
          SizedBox(height: 15 * scaleFactor,),
          dashboardHeader(scaleFactor, "Bicol University Laboratories"),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only( right: 30.0 * scaleFactor,bottom: 40),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SizedBox(width: (screenWidth <= 1366) ? 420*scaleFactor : 480 *scaleFactor ,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            children: [
                              infoHeader(0.8 * scaleFactor, "List of Current Computer Laboratories", "Click to Open and Hold to edit or delete a laboratory"),
                              Expanded(
                                child: (loadingLabs) ? const Align(alignment:Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Text("Loading laboratories.."),
                                  )
                                ) : ListView.builder(
                                  padding: EdgeInsets.only(top:10.0 ,right: 30.0 * scaleFactor,left: 40.0),
                                  itemCount: laboratories.length+1,
                                  itemBuilder: (context, int index){
                                    return  CategoryButton(mainText:(index < laboratories.length)? laboratories[index].laboratory : "", 
                                        leftText: (index < laboratories.length) ? "${laboratories[index].units}" : "",  
                                        isActive: (_activeLab == index+1),
                                        hasError: (_hasDefective && _activeLab == index+1),
                                        expandButton: (index == laboratories.length),
                                        onLongPress: (){
                                          if(index!=laboratories.length) {
                                            department.text = laboratories[index].department;
                                            laboratory.text = laboratories[index].laboratory;
                                            showDialog(
                                            context: context,
                                            builder:(context) => AlertDialog(
                                              contentPadding: EdgeInsets.zero,
                                              clipBehavior: Clip.antiAlias,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text("Edit Laboratory"),
                                                   SizedBox(
                                                        height: 35 * scaleFactor,
                                                        width:120.0,
                                                        child: DecoratedBox(
                                                          decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                            color: Colors.red
                                                          ),
                                                          child: FittedBox(
                                                            fit : BoxFit.contain,
                                                            child: TextButton(
                                                              onPressed: () async{
                                                              await showDialog(context: context, 
                                                              builder: (context) => AlertDialog(
                                                                title: const Text("Are you sure you want to delete this laboratory and its contents?") ,
                                                                actions:[
                                                                  TextButton(onPressed: (){
                                                                    delete(laboratories[index].id, "laboratories");
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: const Text("Delete")),
                                                                  TextButton(onPressed: (){
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: const Text("Cancel"))
                                                                ]
                                                              )
                                                              );
                                                              // ignore: use_build_context_synchronously
                                                              Navigator.of(context).pop();
                                                            }, 
                                                              child: const Padding(
                                                                padding: EdgeInsets.all(5.0),
                                                                child: Text("Delete Laboratory", style: TextStyle(color: Colors.white),),
                                                              )
                                                            ),
                                                          ),
                                                        ),
                                                      ),  
                                                ],
                                              ),
                                              content: SizedBox(
                                                width: 500,
                                                height: 300.0,
                                                child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                      Expanded(child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(child:
                                                          Column(
                                                            children: [
                                                              SizedBox(height: 10.0 *scaleFactor,),
                                                   
                                                              TextFormField(
                                                                readOnly: true,
                                                                controller: department,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Department",
                                                                  hintText: "e.g Computer Studies Department",
                                                                ),
                                                              ),
                                  
                                                              SizedBox(height: 20.0 *scaleFactor,),
                                                              TextFormField(
                                                                controller: laboratory,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Laboratory",
                                                                  hintText: "e.g Computer Laboratory 1",
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ),
                                                      )),
                                                      SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                                        child: DecoratedBox(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.deepOrange,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: [
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: (){
                                                                  changeLabName(laboratories[index].id);
                                                                  Navigator. of(context). pop();
                                                                },
                                                                child: Text("Save",
                                                                  style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: ()=>{
                                                                    Navigator. of(context). pop()
                                                                },
                                                                child: Text("Close",
                                                                style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),),
                                                              ),
                                                            )
                                                          ]),
                                                        ),
                                                      )
                                                    ],)
                                              ),
                                            )
                                          );
                                          }
                                        },
                                        onPressed: (){
                                          if(index != laboratories.length){
                                              setState(() {
                                                viewDefectives = false;
                                              });
                                              openLab(index+1);
                                            }else{
                                              showDialog(context: context, 
                                                  builder: (context) => AlertDialog(
                                                    title: const Text("Add New Laboratory"),
                                                    contentPadding: EdgeInsets.zero,
                                                    clipBehavior: Clip.antiAlias,
                                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                                    content: SizedBox(
                                                      width: 500.0,
                                                      height: 300.0,
                                                      child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                            Expanded(child: Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Center(child:
                                                                Column(
                                                                  children: [
                                                                    SizedBox(height: 10.0 *scaleFactor,),
                                                                  TextFormField(
                                                                      controller: department,
                                                                      readOnly: true,
                                                                      decoration: const InputDecoration(
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                        ),
                                                                        labelText: "Department",
                                                                        hintText: "e.g Computer Studies Deparment",
                                                                      ),
                                                                    ),
                                                                     SizedBox(height: 20.0 *scaleFactor,),
                                                                    TextFormField(
                                                                      controller: laboratory,
                                                                      decoration: const InputDecoration(
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                        ),
                                                                        labelText: "Laboratory",
                                                                        hintText: "e.g Computer Laboratory 1",
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              ),
                                                            )),
                                                            SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                                              child: DecoratedBox(
                                                                decoration: const BoxDecoration(
                                                                  color: Colors.deepOrange,
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                  children: [
                                                                  Expanded(
                                                                    child: TextButton(
                                                                      onPressed: (){
                                                                        createLab();
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child: Text("Add",
                                                                        style: TextStyle(
                                                                          color:Colors.white,
                                                                          fontSize: 20*scaleFactor
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: TextButton(
                                                                      onPressed: ()=>{
                                                                         Navigator. of(context). pop()
                                                                      },
                                                                      child: Text("Cancel",
                                                                      style: TextStyle(
                                                                          color:Colors.white,
                                                                          fontSize: 20*scaleFactor
                                                                        ),),
                                                                    ),
                                                                  )
                                                                ]),
                                                              ),
                                                            )
                                                          ],)
                                                    ),
                                                  )
                                                  );
                                            }
                                        });
                                  }
                                  ),
                              ),
                            ],
                          )
                          ),
                      ),
                     Padding(padding: const EdgeInsets.only(bottom: 0.0),
                        child: SizedBox(width: 3 * scaleFactor,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:  Color.fromARGB(167, 13, 19, 27),))
                        ),
                      ),
                      SizedBox(width: 30 *scaleFactor,),
                      Expanded(
                        child: Padding(padding:EdgeInsets.only(right: 0.0 * scaleFactor,top: 20.0),
                         child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                Flexible(
                                  child: SizedBox(height: 50.0 *scaleFactor, width: (screenWidth <= 1366) ? 250*scaleFactor : 350.0 * scaleFactor,
                                    child: TextFormField(
                                      controller: searchDevice,
                                      onChanged: (input)=>setState((){}),
                                      decoration: const InputDecoration(
                                        labelText: "Search Device",
                                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0)))
                                        )
                                      ),
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.only(left: 20.0),
                                  child: TextButton(
                                    onPressed: ()=>{
                                       if(_activeLab != 0) showDialog(context: context, 
                                            builder: (context) => AlertDialog(
                                              title: const Text("Add Devices"),
                                              contentPadding: EdgeInsets.zero,
                                              clipBehavior: Clip.antiAlias,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                              content: SizedBox(
                                                width: 500.0,
                                                height: 300.0,
                                                child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                      Expanded(child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(child:
                                                          Column(
                                                            children: [
                                                              SizedBox(height: 10.0 *scaleFactor,),
                                                              TextFormField(
                                                                controller: prefix,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Prefix Name",
                                                                  hintText: "e.g PC"
                                                                ),
                                                              ),
                                                              SizedBox(height: 20.0 *scaleFactor,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SizedBox(
                                                                width: 120.0,
                                                                child: TextFormField(
                                                                controller:  startIndex,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Start Index",
                                                                  hintText: "e.g 1",
                                                                ),
                                                              ),
                                                              ),
                                                              Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                child: Icon(Icons.add, size: 32.0 * scaleFactor,),
                                                              ),
                                                              SizedBox(
                                                                width: 250.0,
                                                                child: TextFormField(
                                                                controller: noOfDevices,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "No. of Devices",
                                                                  hintText: "e.g 15 (PC-001 to PC-015)",
                                                                ),
                                                              ),
                                                              )
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        ),
                                                      )),
                                                      SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                                        child: DecoratedBox(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.deepOrange,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: [
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: (){
                                                                  createDevices();
                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Text("Add",
                                                                  style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: ()=>{
                                                                   Navigator. of(context). pop()
                                                                },
                                                                child: Text("Cancel",
                                                                style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),),
                                                              ),
                                                            )
                                                          ]),
                                                        ),
                                                      )
                                                    ],)
                                              ),
                                            )
                                            )
                                    },
                                    child: Row(children: [
                                      Icon(Icons.devices,
                                        color: (_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text("Add Devices" ,
                                        style: TextStyle(color:(_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ))
                                    ]),
                                  ),
                                ),
   
                                TextButton(
                                    onPressed: ()=>{
                                      if(_activeLab != 0){
                                        if(viewDefectives){
                                          setState((){
                                            viewDefectives = false;
                                          })
                                        }else{
                                          setState((){
                                            viewDefectives = true;
                                          })
                                        }
                                      }
                                    },
                                    child: Row(children: [
                                      Icon(Icons.devices,
                                        color: (_activeLab == 0) ? Colors.grey : (viewDefectives) ? Colors.blue : Colors.red,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text( (viewDefectives) ? "View all" : "View Defectives" ,
                                        style: TextStyle(color:(_activeLab == 0) ? Colors.grey : (viewDefectives) ? Colors.blue : Colors.red,
                                      ))
                                    ]),
                                  ),
                                TextButton(
                                    onPressed: ()=>{
                                      if(_activeLab != 0){
                                        printQRs()
                                      }
                                    },
                                    child: Row(children: [
                                      Icon(Icons.devices,
                                        color: (_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text("Print QRs" ,
                                        style: TextStyle(color:(_activeLab == 0) ? Colors.grey :  Colors.blue,
                                      ))
                                    ]),
                                  ),
                              ],
                            ),
                            Expanded(child: (devices.isEmpty && _activeLab != 0)? const Center(
                                child: Text("No devices in this laboratory"),
                              ) : (loadingDevices) ? const Center(
                                child: Text("Loading..")) :
                              ListView.builder(
                              padding: EdgeInsets.only(right: 10.0 * scaleFactor, top: 10.0),
                              itemCount: devices.length,
                              itemBuilder: (context, int index){
                                return (viewDefectives && !devices[index].isDefective() || 
                                (searchDevice.text != "" && !devices[index].name.toLowerCase().contains(searchDevice.text.toLowerCase()))) ? const SizedBox() : DeviceButton(device: devices[index],
                                    editDevice: () {
                                      showDialog(context: context, 
                                       builder:(context) => AlertDialog(
                                        clipBehavior: Clip.antiAlias,
                                        contentPadding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                        title: SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(devices[index].name),
                                              SizedBox(width:20.0 *scaleFactor),
                                              SizedBox(
                                                  height: 35 * scaleFactor,
                                                  width:120.0,
                                                  child: DecoratedBox(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                      color: Colors.red
                                                    ),
                                                    child: FittedBox(
                                                      fit : BoxFit.contain,
                                                      child: TextButton(onPressed: ()async{
                                                        await showDialog(context: context, 
                                                        builder: (context) => AlertDialog(
                                                          title: const Text("Are you sure you want to remove this device?") ,
                                                          actions:[
                                                            TextButton(onPressed: (){
                                                              delete(devices[index].id, "devices");
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Delete")),
                                                            TextButton(onPressed: (){
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Cancel"))
                                                          ]
                                                        )
                                                        );
                                                        // ignore: use_build_context_synchronously
                                                        Navigator.of(context).pop();
                                                      }, 
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(5.0),
                                                          child: Text("Delete Device", style: TextStyle(color: Colors.white),),
                                                        )
                                                      ),
                                                    ),
                                                  ),
                                                ),  
                                            ],
                                          ),
                                        ),
                                        content: SizedBox(
                                          width: 600.0,
                                          height: 350.0,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: 10*scaleFactor,),
                                                      Row(children: [
                                                        SizedBox(
                                                          height: 60.0 *scaleFactor,
                                                          width: 300.0,
                                                          child: TextFormField(
                                                            style:TextStyle(fontSize: 18*scaleFactor),
                                                          readOnly:true,
                                                          initialValue: (devices[index].lastSession != null) ? devices[index].lastSession!.student: "None",
                                                          decoration: const InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                                labelText: "Last User",
                                                              ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 20*scaleFactor),
                                                        SizedBox(
                                                          height: 60.0 *scaleFactor,
                                                          width: 170.0,
                                                          child: TextFormField(
                                                            style:TextStyle(fontSize: 18*scaleFactor),
                                                          readOnly: true,
                                                          initialValue: (devices[index].lastSession != null) ? devices[index].lastSession!.timestamp : "None",
                                                          decoration: const InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                                labelText: "Last Session",
                                                              ),
                                                          ),
                                                        )
                                                      ],),
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 15.0 * scaleFactor),
                                                          child: Row(
                                                            children: [  SizedBox(
                                                                height: 60.0 *scaleFactor,
                                                                width: 220.0,
                                                                child: TextFormField(
                                                                  style:TextStyle(fontSize: 18*scaleFactor),
                                                                readOnly: true,
                                                                initialValue: (devices[index].lastSession != null) ? devices[index].lastSession!.lastSeen : "None",
                                                                decoration: const InputDecoration(
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                      ),
                                                                      labelText: "Last Seen",
                                                                    ),
                                                                ),
                                                              ),
                                                              const SizedBox(width:15.0),
                                                              SizedBox(
                                                                height: 45 * scaleFactor,
                                                                width: 140.0,
                                                                child: DecoratedBox(
                                                                  decoration: const BoxDecoration(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                    color: Colors.blue
                                                                  ),
                                                                  child: FittedBox(
                                                                    fit : BoxFit.contain,
                                                                    child: TextButton(onPressed: (){
                                                                      loadSessionHistory(devices[index]).then((value) => {
                                                                         showDialog(context: context, builder: (context) => AlertDialog(
                                                                          backgroundColor: Colors.transparent,
                                                                            content: Container(
                                                                              clipBehavior: Clip.antiAlias,
                                                                              decoration:const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                                                                color: Colors.white
                                                                              ),
                                                                              width: 450,
                                                                              height: 600,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                                                                                child: (value.isEmpty)? const Center(child:Text("No sessions found.")) : ListView.builder(
                                                                                  itemCount: value.length,
                                                                                  itemBuilder: (context,index){
                                                                                    return  SessionHistoryButton(session: value[index], type: "admin",);
                                                                                                            
                                                                                },),
                                                                              ),
                                                                            )
                                                                        ))
                                                                      });
                                                                     
                                                                    }, 
                                                                      child: const Padding(
                                                                        padding: EdgeInsets.all(10.0),
                                                                        child: Text("View History", style: TextStyle(color: Colors.white),),
                                                                      )
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),  
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15*scaleFactor,
                                                      ),
                                                      Row(children: [
                                                        SizedBox(
                                                          height: 50.0 *scaleFactor,
                                                          width: 140.0,
                                                          child: TextFormField(
                                                          readOnly: true,
                                                          textAlign: TextAlign.center,
                                                          initialValue: "Inventory",
                                                          decoration: const InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                              ),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                          child: Center(child: Icon(Icons.arrow_right)),
                                                        ),
                                                        DropdownMenu(
                                                          width: 250.0,
                                                          initialSelection: laboratories[_activeLab-1].id,
                                                          onSelected: (String? value)=>{
                                                            setState(() {
                                                              moveID = value!;
                                                            })
                                                          },
                                                          dropdownMenuEntries: laboratories.map<DropdownMenuEntry<String>>((Laboratory laboratory) {
                                                            return DropdownMenuEntry<String>(value: laboratory.id, label: parseAcronym(laboratory.laboratory));
                                                          }).toList(),
                                                        )

                                                      ],),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                              child: DecoratedBox(
                                                decoration: const BoxDecoration(
                                                  color: Colors.deepOrange,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: (){
                                                        moveDevice(devices[index]).then((x)=>{
                                                            Navigator. of(context). pop()
                                                        });
                                                      
                                                      },
                                                      child: Text("Save",
                                                        style: TextStyle(
                                                          color:Colors.white,
                                                          fontSize: 20*scaleFactor
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: (){
                                                          setState(() {
                                                            devices[index].labID = laboratories[_activeLab-1].id;
                                                          });
                                                          Navigator. of(context). pop();
                                                      },
                                                      child: Text("Close",
                                                      style: TextStyle(
                                                          color:Colors.white,
                                                          fontSize: 20*scaleFactor
                                                        ),),
                                                    ),
                                                  )
                                                ]),
                                              ),
                                            )
                                            ],
                                          ),
                                        ),
                                        
                                        ));
                                    },
                                  );
                              }
                              ),
                              )
                          ],)
                          ),
                        )
                      )
            ]),)
          ),
        ],
      );
      case 2:
       if(callOnce != widget.content){
                setState((){
                    accounts = [];
                  _activeCategory = 0;
                
                });
                searchAccount.text = "";
                callOnce = widget.content;
        }
        return Column(
        children: [
          SizedBox(height: 15 * scaleFactor,),
          dashboardHeader(scaleFactor, "Account Management"),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(right: 30.0 * scaleFactor,bottom: 40),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SizedBox(width: (screenWidth <= 1366)? 420*scaleFactor : 480 *scaleFactor ,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            children: [
                              infoHeader(0.8 * scaleFactor, "List of Account Categories", "Select an account category"),
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.only(top:10.0, right: 30.0* scaleFactor,left: 40.0),
                                  itemCount: accountTypes.length,
                                  itemBuilder: (context, int index){
                                    return 
                                      CategoryButton(mainText: accountTypes[index], 
                                        leftText: (index+1).toString(),  
                                        isActive: (_activeCategory == index+1),
                                        onPressed: (){
                                          setActive(index+1);
                                          loadAccounts();
                                        },);
                                  }
                                  ),
                              ),
                            ],
                          )
                          ),
                      ),
                      SizedBox(width: 0 *scaleFactor,),
                    Padding(padding: const EdgeInsets.only(bottom: 0.0),
                        child: SizedBox(width: 3 * scaleFactor,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:  Color.fromARGB(167, 13, 19, 27),))
                        ),
                      ),
                      SizedBox(width: 30 *scaleFactor,),
                      Expanded(
                        child: Padding(padding: const EdgeInsets.only(right: 0.0,top: 20.0),
                         child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                Flexible(
                                  child: SizedBox(height: 50.0 *scaleFactor, width: 350.0 * scaleFactor,
                                    child: TextFormField(
                                      controller: searchAccount,
                                            onChanged: (input)=>setState((){}),
                                      decoration: const InputDecoration(
                                        labelText: "Search Account",
                                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))))
                                      ),
                                  ),
                                ),
                                // Padding(padding: const EdgeInsets.only(left: 20.0),
                                //   child: TextButton(
                                    
                                //     onPressed: ()=>{
                                //       // if(_activeLab != 0)

                                //     },
                                //     child: Row(children: [
                                //       Icon(Icons.person,
                                //         color: (_activeCategory != 0) ? Colors.blue: Colors.grey,
                                //       ),
                                //       const SizedBox(width: 10.0,),
                                //       Text("Add Account", style: TextStyle(color: (_activeCategory != 0) ? Colors.blue: Colors.grey,))
                                //     ]),
                                //   ),
                                // ),
                                  // TextButton(
                                  //   onPressed: ()=>{
                                  //   },
                                  //   child: Row(children: [
                                  //     Icon(Icons.group, color:(_activeCategory != 0) ? Colors.blue: Colors.grey,),
                                  //     const SizedBox(width: 10.0,),
                                  //     Text("Group" , style: TextStyle(color :(_activeCategory != 0) ? Colors.blue: Colors.grey,))
                                  //   ]),
                                  // ),
                              ],
                            ),
                            Expanded(child: 
                             (accountTypes.isEmpty && _activeCategory != 0)? const Center(
                                child: Text("No Accounts Available"),
                              ) : (loadingAccounts) ? const Center(child: Text("Loading")) :
                              ListView.builder(
                              padding: const EdgeInsets.only(right: 50.0, top: 10.0),
                              itemCount: accounts.length,
                              itemBuilder: (context, int index){
                                return ((searchAccount.text != "" && !accounts[index].fullname.toString().toLowerCase().contains(searchAccount.text.toLowerCase()))) ? const SizedBox():SizedBox(
                                  height: 70 * scaleFactor,
                                  child: AccountButton(account: accounts[index],
                                    emailcontroller: email,
                                    fullnamecontroller: fullname,
                                    passwordcontroller: password,
                                    contactcontroller: contact,
                                    save: (){
                                      if(accounts[index] is Student){
                                        editAccount(accounts[index].id, "student");
                                      }else if(accounts[index] is Faculty){
                                        editAccount(accounts[index].id, "faculty");
                                      }else{
                                        editAccount(accounts[index].id, "admin");
                                      }
                                    },
                                    delete: ()=>{
                                      if(accounts[index] is Student){
                                        delete(accounts[index].id, "students")
                                      }else if(accounts[index] is Faculty){
                                        delete(accounts[index].id, "faculty")
                                      }
                                    }
                                  ),
                                );
                              }
                              ),)
                          ],)
                          ),
                        )
                      )
            ]),)
          ),
        ],
      );
      case 3:
        if(callOnce != widget.content){
                loadClassSessions();
                callOnce = widget.content;
        }
        return Column(
        children: [
         SizedBox(height: 15 * scaleFactor,),
          dashboardHeader(scaleFactor,"Generated Reports"),
            Expanded(
              child:Padding(padding: const EdgeInsets.all(0.0),
                      child:
                      (loadingClassSessions)? const Center(child:Text("Loading")) :  (_reports.isEmpty) ? const Center(child:Text("No reports currently.")) :Align(
                        alignment: Alignment.topCenter,
                        child: 
                          Padding(
                            padding:  EdgeInsets.only(top:10.0 ,bottom: 60.0*scaleFactor ,left: 80.0, right: 80.0),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                               decoration: const BoxDecoration(color:Colors.white, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                               clipBehavior: Clip.antiAlias,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columnSpacing: 0,
                                      dividerThickness: 2.0,
                                      showBottomBorder: true,
                                      horizontalMargin: 40.0,
                                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.orange),
                                      headingTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16*scaleFactor, color: Colors.white),
                                      dataTextStyle: TextStyle(fontSize: 16*scaleFactor),
                                      columns:getColumns(columns),
                                      rows: getReports()
                                    ),
                                  ),
                            
                            ),
                          )
                          ,)
                      )
            )
        ],
      );
      case 4:
        if(callOnce != widget.content){
          setState((){
            _activeCategory = 0;
            refresh();
          });
          callOnce = widget.content;
        }
        return Column(
        children: [
          SizedBox(height: 15 * scaleFactor,),
          dashboardHeader(scaleFactor, "Account Verification"),
          Expanded(
            child: Padding(
                padding:EdgeInsets.only( right: 30.0 * scaleFactor,bottom: 40),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SizedBox(width:  (screenWidth <= 1366) ? 420*scaleFactor : 480 *scaleFactor ,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            children: [
                              infoHeader(0.8 * scaleFactor, "List of Account Categories", "Select an account category"),
                              Expanded(
                                child: ListView.builder(
                                  padding:  EdgeInsets.only(top:10.0 ,right: 30.0 * scaleFactor,left: 40.0),
                                  itemCount: accountTypes.length-1,
                                  itemBuilder: (context, int index){
                                    return CategoryButton(mainText: accountTypes[index+1], 
                                        leftText: (index+1).toString(),  
                                        isActive: (_activeCategory == index+1),
                                        hasPending: (index+1==1)? facultyHasPending : studentHasPending ,
                                        onPressed: (){
                                          setActive(index+1);
                                          refresh();
                                        },);
                                  }
                                  ),
                              ),
                            ],
                          )
                          ),
                      ),
                      SizedBox(width: 0 *scaleFactor,),
                     Padding(padding: const EdgeInsets.only(bottom: 0.0),
                        child: SizedBox(width: 3 * scaleFactor,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:  Color.fromARGB(167, 13, 19, 27),))
                        ),
                      ),
                      SizedBox(width: 30 *scaleFactor,),
                      Expanded(
                        child: Padding(padding: const EdgeInsets.only(right: 30.0,top: 20.0),
                         child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(left: 20.0),
                                  child: TextButton(
                                    onPressed: ()=>{
                                      if(_activeCategory != 0 && !verificationUpdate) deleteAllRequests(_activeCategory)
                                    },
                                    child: Row(children: [
                                      Icon(Icons.group_remove, color:(_activeCategory!=0 && !verificationUpdate) ? Colors.red : Colors.grey),
                                      const SizedBox(width: 10.0,),
                                      Text("Delete All Requests", style: TextStyle(color:(_activeCategory!=0 && !verificationUpdate) ? Colors.red : Colors.grey),)
                                    ]),
                                  ),
                                ),
                                TextButton(
                                  onPressed: ()=>{
                                    if(_activeCategory != 0 && !verificationUpdate) acceptAllRequests(_activeCategory)                          
                                  },
                                  child:  Row(children: [
                                    Icon(Icons.group_add,color:(_activeCategory!=0 && !verificationUpdate ) ? Colors.blue : Colors.grey),
                                    const SizedBox(width: 10.0,),
                                    Text("Accept All Request",style: TextStyle(color:(_activeCategory!=0 && !verificationUpdate) ? Colors.blue : Colors.grey))
                                  ]),
                                ),
                                TextButton(
                                    onPressed: ()=>{
                                     if(_activeCategory != 0) refresh()
                                    },
                                    child:  Row(children: [
                                      Icon(Icons.refresh,color:(_activeCategory!=0) ? Colors.blue : Colors.grey),
                                      const SizedBox(width: 10.0,),
                                      Text("Refresh",style: TextStyle(color:(_activeCategory!=0) ? Colors.blue : Colors.grey))
                                    ]),
                                  ),
                               
                              ],
                            ),
                            Expanded(child: 
                             (accountTypes.isEmpty && _activeCategory != 0)? const Center(
                                child: Text("No Accounts Available"),
                              ) :
                              (errorMessage == null) ? StreamBuilder(
                                stream: _streamController.stream,
                                builder: (context, snapshot) {
                                  if(_activeCategory == 0){
                                    return const Center(child: Text(""));
                                  }
                                  if(snapshot.hasData){
                                    if(snapshot.data.length > 0){
                                      var data = snapshot.data;
                                      subjects =[];
                                      data.forEach((dynamic row) => {
                                         if(row['account'] == _activeCategory.toString()) subjects.add(Verification(
                                          accountType: row['account'].toString(),
                                          id : row['ID'].toString(),
                                          fullname : row['fullname'].toString(),
                                          email : row['email'].toString(),
                                          contact : row['contact'].toString(),
                                          password : row['password'].toString(),
                                          deviceToken: row['devicetoken'].toString(),
                                         ))
                                      });
                                      // WEBSOCKET IMPLEMENTATION
                                  // if(snapshot.hasData){
                                  //   if(snapshot.data != "[]"){
                                  //     var data = json.decode(snapshot.data);
                                  //     var subjects = [];
                                  //     data.forEach((String index ,dynamic row) => {
                                  //        if(row['accountType'] == _activeCategory.toString())subjects.add(Verification(
                                  //         accountType: row['accountType'],
                                  //         id : row['id'],
                                  //         fullname : row['fullname'],
                                  //         email : row['email'],
                                  //         contact : row['contact'],
                                  //         password : row['password'],
                                  //        ))
                                  //     });
                                      if(subjects.isNotEmpty) {
                                        return  (verificationUpdate) ? const Center(child:Text("Loading")) : ListView.builder(
                                            padding: const EdgeInsets.only(right: 30.0, top: 10.0),
                                            itemCount: subjects.length,
                                            itemBuilder: (context, int index){
                                              return Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Container(
                                                  height: 50 * scaleFactor,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                    boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.4),
                                                          spreadRadius: 3,
                                                          blurRadius: 3,
                                                          offset: const Offset(0, 2), // changes position of shadow
                                                        ),
                                                      ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: Row(
                                                      children:[
                                                        const Icon(Icons.person),
                                                        const SizedBox(width:15),
                                                        Expanded(child: SingleChildScrollView(
                                                          scrollDirection : Axis.horizontal,
                                                          child: Text(subjects[index].fullname, style: const TextStyle(fontWeight: FontWeight.w500)))),
                                                        const SizedBox(width:15.0),
                                                        Container(height: 35*scaleFactor,
                                                          width: 120.0,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration:const BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                              color:Color.fromARGB(255, 255, 216, 202),
                                                            ),
                                                          child:Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                              child: Center(
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(Icons.email),
                                                                      const SizedBox(width: 10),
                                                                      Expanded(
                                                                        child: SingleChildScrollView(
                                                                          scrollDirection: Axis.horizontal,
                                                                          child: Text(
                                                                            subjects[index].email,
                                                                             style:  TextStyle(fontWeight: FontWeight.w400, fontSize:18*scaleFactor)
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                            ),
                                                          
                                                          ),
                                                        const SizedBox(width:15),
                                                        SizedBox(width:40,
                                                          child: TextButton(
                                                            onPressed: (){
                                                              reject(subjects[index]);
                                                            },
                                                            child: const Align(
                                                              alignment: Alignment.center,
                                                              child: Icon(Icons.close, color:Colors.red),))
                                                        ),
                                                        const SizedBox(width:5),
                                                        SizedBox(width:40,
                                                           child: TextButton(
                                                            onPressed: ()=>{
                                                                verify(subjects[index])
                                                            },
                                                            child: const Align(
                                                              alignment: Alignment.center,
                                                              child: Icon(Icons.check, color:Colors.green),))
                                                        ),
                                                      ]
                                                    ),
                                                  )
                                                ),
                                              );
                                            }
                                        );
                                      }else{
                                        return const Center(child: Text("There are no verification requests"));
                                      }
                                    }else{
                                      return const Center(child: Text("There are no verification requests"));
                                    }
                                  }else{
                                    return const Center(child: Text(
                                        "There are no verification requests"
                                      ));
                                  }
                                },
                              ) :const Center(child: Text(
                                        "Unable to connect to the server"
                                      )),)
                          ],)
                          ),
                        )
                      )
            ]),)
          ),
        ],
      );
      case 5:
       if(callOnce != widget.content){
                loadCourses();
                callOnce = widget.content;
        }
        return Column(
        children: [
         SizedBox(height: 15 * scaleFactor,),
         dashboardHeader(scaleFactor, "Manage Courses"),
            Expanded(
              child:Padding(padding: const EdgeInsets.all(0.0),
                      child:
                      Align(
                        alignment: Alignment.topCenter,
                        child: 
                          Padding(
                            padding:  EdgeInsets.only(top:10.0 ,bottom: 10.0*scaleFactor ,left: 80.0, right: 120.0),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                               decoration: const BoxDecoration(color:Colors.white, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                               clipBehavior: Clip.antiAlias,
                                  child: (loadingCourses)? const Center(child:Text("Loading")) :SingleChildScrollView(
                                    child: DataTable(
                                      dividerThickness: 2.0,
                                      showBottomBorder: true,
                                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.orange),
                                      headingTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16*scaleFactor, color: Colors.white),
                                      dataTextStyle: TextStyle(fontSize: 16*scaleFactor),
                                      columns:getColumns(courseColumns),
                                      rows: getCourses(scaleFactor)
                                    ),
                                  ),
                          
                            ),
                          )
                          ,)
                      )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom:30.0, right:100.0),
              child: SizedBox(
                width:double.infinity,
                height:50.0*scaleFactor,
                child:Align(
                  alignment:Alignment.centerRight,
                  child: SizedBox(
                    width:150,
                    height: double.infinity,
                    child:DecoratedBox(decoration:const BoxDecoration(color: Colors.blue,
                      borderRadius:BorderRadius.all(Radius.circular(15.0))
                    ),
                      child: TextButton(child: const Icon(Icons.add,color:Colors.white), onPressed:()=>{
                          showDialog(context:context, builder: (context){
                            return manageCourse(1, null, null, courseController,    (){
                              setState(() {});
                              addCourse();
                            },()=>{
                               deleteCourse(null)
                            });
                          })
                      }),
                    )
                  ),
                )
              ),
            )
        ],
      );
      default:
       return const Text("Error.");
    }
  }
}