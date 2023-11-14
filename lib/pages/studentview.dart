import 'dart:async';
import 'dart:convert';

import 'package:bupolangui/components/custombuttons.dart';
import 'package:bupolangui/components/popups.dart';
import 'package:bupolangui/components/preloader.dart';
import 'package:bupolangui/constants/constants.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/main.dart';
import 'package:bupolangui/models/course.dart';
import 'package:bupolangui/models/laboratory.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/models/schedule.dart';
import 'package:bupolangui/models/session.dart';
import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:bupolangui/pages/viewprofile.dart';
import 'package:bupolangui/printables/qrs.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as server;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class StudentView extends StatefulWidget {
  final String title;
  final Student student;
  const StudentView({super.key, required this.title, required this.student});

  @override
  State<StudentView> createState() => _StudentView();
}

class _StudentView extends State<StudentView> {
  Timer? _timer; 
  List<Session>? _sessions;

  bool refreshing = false;

  Future refresh() async{
    setState(() {
      refreshing = true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/student_refresh.php");
    var response = await server.post(url, body: {
      "id": widget.student.id,
    }); 
    var data = json.decode(response.body);
    if(!data['success']){
      print("Error");
    }else{
      if(mounted){
        setState(() {
          widget.student.QR = data['QR'];
          refreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds:500),
            content: Text('QR refreshed')),
        );
      }
    }
  }

bool loadingHistory = false;

Future<List<Session>> loadSessionHistory() async{
  setState(() {
    loadingHistory = true;
  });
  List<Session> sessions = [];
    var url = Uri.parse("${Connection.host}flutter_php/student_getsessions.php");
    var response = await server.post(url, body: {
      "id": widget.student.id,
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
      setState(() {
      loadingHistory = false;
    });
    return sessions;
  }


  @override
  void initState() {
    super.initState();
     tz.initializeTimeZones();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_timer!=null){
      _timer!.cancel();
    }
  }

  int page = 0;
  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height/1000;
    return WillPopScope(
      onWillPop: () async {
        if(page>0){
          setState(() {
            page-=1;
          });
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("STUDENT PORTAL",style: TextStyle(fontWeight: FontWeight.bold),),
          automaticallyImplyLeading: false,
          leading: (page<=0) ? null : SizedBox(
                  width: 80.0*scaleFactor,
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        page -=1;
                      });
                    },
                    child: const Icon(Icons.arrow_back, color:   Colors.white,),
                  ),
                ),
          actions: [
            SizedBox(width: 80*scaleFactor,
              child: InkWell(
                child: const Icon(Icons.menu),
                onTap: (){
                  showDialog(context:context, builder:(context)=>
                        SimpleDialog(
                          alignment: Alignment.bottomCenter,
                          backgroundColor: Colors.transparent,
                          children:[
                             SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                                ),
                                child: const Text("PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:() async{
                                  var studentUpdate =  await Navigator.push(
                                      context,
                                    PageRouteBuilder(
                                        pageBuilder: (context , anim1, anim2) =>
                                            ViewProfile(account: widget.student)));
                                  if(studentUpdate!=null){
                                    setState(() {
                                      widget.student.fullname = studentUpdate.fullname;
                                      widget.student.contact = studentUpdate.contact;
                                      widget.student.block = studentUpdate.block;
                                    });
                                  }
                                }),
                            ),
                            const SizedBox(height: 20,),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                                ),
                                child: const Text("LOGOUT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:() async{
                                    SharedPreferences prefs =  await SharedPreferences.getInstance();
                                    await prefs.remove('ID');
                                    await prefs.remove('Type');
                                     try{
                                      final GoogleSignIn googleSignIn = GoogleSignIn(
                                        scopes: [
                                          'email',
                                          'https://www.googleapis.com/auth/contacts.readonly',
                                        ],
                                      );
                                      await googleSignIn.disconnect();
                                    }catch(e){
                                      print("Google SignIn failed");
                                    }
                                   Navigator.pushReplacement(
                                      context,
                                    PageRouteBuilder(
                                        pageBuilder: (context , anim1, anim2) =>
                                            const LandingPage()));
                                }),
                            ),
                          ]
                        )
                      );
                },
              ),
            )
          ],
        ),
        body:
        (page==1)? Column(children: [
           SizedBox(
                    width: double.infinity,
                    height: 25*scaleFactor,
                    child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                  ),
                  SizedBox(
                  width: double.infinity,
                  height: 90*scaleFactor,
                  child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 200, 238, 255)),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                        TextSpan(text: "HISTORY\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                        TextSpan(text: "Viewing your session history.\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
                      ])),
                    ),
                  ),
                ),
                 SizedBox(
                    width: double.infinity,
                    height: 20*scaleFactor,
                    child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: (_sessions!.isEmpty) ? const Center(child: Text("Empty."),) : ListView.builder(
                      itemCount: _sessions!.length,
                      itemBuilder: ((context, index) {
                        return SessionHistoryButton(session: _sessions![index],type: "student",);
                      }),
                    ),
                  ))
        ],):
        Column(
          children: [
               SizedBox(
                    width: double.infinity,
                    height: 25*scaleFactor,
                    child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                  ),
                  SizedBox(
                  width: double.infinity,
                  height: 90*scaleFactor,
                  child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 200, 238, 255)),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                        TextSpan(text: "${widget.student.fullname.toUpperCase()}\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                        TextSpan(text: "Welcome to the students portal!\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
                      ])),
                    ),
                  ),
                ),
                 SizedBox(
                    width: double.infinity,
                    height: 20*scaleFactor,
                    child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                  ),
              SizedBox(height: 50*scaleFactor,),
            Center(
                child: QrImageView(
                  data: widget.student.QR!,
                  version: QrVersions.auto,
                  size: 350.0 * scaleFactor,
                  ),
              ),
               SizedBox(height: 60*scaleFactor,),
               SizedBox(
                  height:50*scaleFactor,
                  width: double.infinity,
                  child:Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: (loadingHistory)? Colors.grey: Colors.blue,
                          // border: Border.all(width: 3.0, color: Colors.orange),
                          borderRadius: const BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: TextButton(child: Center(child: Text((loadingHistory)? "LOADING" : "HISTORY", style: const TextStyle(color: Colors.white,letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 20),)),
                          onPressed: ()=>{
                           if(!loadingHistory){
                            loadSessionHistory().then((sessions) => {
                                setState((){
                                  _sessions = sessions;
                                  page+=1;
                                })
                            } )
                           }
                          },
                        ),
                      ),
                  ),
            ),
            
              SizedBox(height: 10*scaleFactor,),
              SizedBox(
                    height: 50*scaleFactor,
                    width: double.infinity,
                    child:Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: DecoratedBox(
                          decoration: BoxDecoration(color: (refreshing)? Colors.grey :  Colors.orange.shade700,
                          //  border: Border.all(width: 3.0, color: Colors.orange),
                            borderRadius: const BorderRadius.all(Radius.circular(20.0))
                          ),
                          child: TextButton(child: Center(child: Text((refreshing)? "REFRESHING" : "REFRESH", style: const TextStyle(color: Colors.white,letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 20),)),
                            onPressed: (){
                              refresh();
                            },
                          ),
                        ),
                    ),),
             SizedBox(height: 10*scaleFactor,),
             SizedBox(
                  height: 50*scaleFactor,
                  width: double.infinity,
                  child:Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DecoratedBox(
                        decoration: BoxDecoration(color:  Colors.blue,
                          borderRadius: const BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: TextButton(child: const Center(child: Text("SCHEDULES", style: TextStyle(color: Colors.white,letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 20),)),
                          onPressed: () async{
                           var accountUpdate =  await Navigator.push(
                              context,
                            PageRouteBuilder(
                                pageBuilder: (context , anim1, anim2) =>
                                    StudentSchedule(student: widget.student)));
                            if(accountUpdate!=null){
                                setState((){
                                  widget.student.fullname = accountUpdate.fullname;
                                  widget.student.contact = accountUpdate.contact;
                                  widget.student.block = accountUpdate.block;
                                });
                            } 
                          },
                        ),
                      ),
                  ),),
                   SizedBox(height: 10*scaleFactor,),
                  SizedBox(
                  height: 50*scaleFactor,
                  width: double.infinity,
                  child:Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DecoratedBox(
                        decoration: BoxDecoration(color:  Colors.green,
                          borderRadius: const BorderRadius.all(Radius.circular(20.0))
                        ),
                        child: TextButton(child: const Center(child: Text("SAVE QR", style: TextStyle(color: Colors.white,letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 20),)),
                          onPressed: () async{
                            final doc = pw.Document();
                             doc.addPage(pw.Page(
                                pageTheme: pw.PageTheme(
                                  pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 0, marginTop: 0, marginRight: 0, marginLeft: 0),
                                ),
                                  build: (pw.Context context) {
                                    return buildStudentQR(widget.student.QR!);
                                  })); // Pag
                            await Printing.layoutPdf(
                                onLayout: (PdfPageFormat format) async => doc.save()
                              );
                          },
                        ),
                      ),
                  ),),
          ],
        )
      ),
    );
  }

}




class StudentSchedule extends StatefulWidget {
  final Student student;
  const StudentSchedule({super.key, required this.student});

  @override
  State<StudentSchedule> createState() => _StudentScheduleState();
}


class _StudentScheduleState extends State<StudentSchedule> {

  final int _currentTab = 0;
  bool _hasLoaded = false;
  Map<String,List<Schedule>> _schedules = {};
  List<int> collapsed = [];
  String? _optionLabID;


  Map<String, Laboratory> _laboratories={};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLaboratories().then((x)=>{
      loadSchedules().then((x)=>{
        if(mounted){
          setState((){
            _hasLoaded = true;  
          })
        }        
      })
    });
  }


  Future loadLaboratories() async{
      var url = Uri.parse("${Connection.host}flutter_php/getLabs.php");
      var response = await server.get(url);
      var data = json.decode(response.body);
      if(data['success']){
        var rows = data['rows'];
        Map<String,Laboratory> laboratories = {};
        rows.forEach((dynamic row) {
          laboratories[parseAcronym(row['laboratory'])] = decodeLaboratory(row);
        });
        if(mounted){
          setState(() {
            _laboratories = laboratories;
          }); 
        }
      }else{
        print(data['message']);
      }
  }
  Future loadSchedules()async{
      var url = Uri.parse("${Connection.host}flutter_php/student_getschedules.php");
      var response = await server.post(url, body: {
        'id': widget.student.id,
      });
      var data= json.decode(response.body);
      if(data['success']){
        var rows=  data['rows'];
        Map<String, List<Schedule>> schedules= {};
        rows.forEach((row){
          if(!schedules.containsKey(row['day'].toString().toUpperCase())){
              schedules[row['day']] = [];
          }
          schedules[row['day']]!.add( decodeSchedule(row));
        }); 
        if(mounted){
           if(defaultTargetPlatform == TargetPlatform.android){
              await flutterLocalNotificationsPlugin.cancelAll();
              // Add new notification based on schedules
              schedules.forEach((day, scheduleList){
                for (var schedule in scheduleList) {
                  scheduleAlarm(schedule, offset: 1000);
                }
              });
            }
          setState(() {
              _schedules = schedules;
          });
        }
      }
  }

  Future addSchedule() async{
      var url = Uri.parse("${Connection.host}flutter_php/student_addschedule.php");
      var response = await server.post(url, body: {
        'id': widget.student.id,
        'labID': _optionLabID!,
        'blockID' : widget.student.block!,
        'day': weekdays.indexOf(selectedDay!.toUpperCase()).toString(),
        'time' : "${timeFromPicker(startTime!)} - ${timeFromPicker(endTime!)}",
      });
      var data= json.decode(response.body);
      if(!data['success']){
        print("Error");
      }
  }

  // Add popup
  

  List<Course> assignedCourses = [];

  List<Course> availableCourses = [];
  
  List<String> takenBlocks = [];
  List<Report> facultyReports = [];

  List<String> weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY","FRIDAY", "SATURDAY"];
  String? selectedDay;

  TimeOfDay? startTime;
    TimeOfDay? endTime;

    TextEditingController levelController = TextEditingController();
      TextEditingController blockController = TextEditingController();

        Map<String, String> selections = {};

  Map<String, String> addOptions = {};


  List<Widget> showSchedule(String day,double scaleFactor){
    List<Widget> widgets = [];
    if(_schedules.containsKey(weekdays.indexOf(day.toUpperCase()).toString())){
      for (var schedule in _schedules[weekdays.indexOf(day.toUpperCase()).toString()]!) {
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
        if(_optionLabID == null || _optionLabID == schedule.labID){
          widgets.add(Column(children:[
          SizedBox(
            width:double.infinity,
            height:30.0,
            child: DecoratedBox(decoration:const BoxDecoration(
              color:Color.fromARGB(221, 15, 15, 15)
            ),
            child: TextButton(
              onPressed: (){},
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(schedule.time, style:const TextStyle(color:Colors.white, fontWeight: FontWeight.bold,letterSpacing:1.2))),
              ),
            ),
            ),
          ),
          SizedBox(
            width:double.infinity,
            height:50.0,
            child: DecoratedBox(decoration:const BoxDecoration(
              color:Color.fromARGB(255, 250, 253, 255)
            ),
            child: TextButton(
              onPressed: (){},
               onLongPress: (){
                showDialog(context: context, builder: (context)=>AlertDialog(
                  title: const Text("Are you sure you want to delete schedule?"),
                  actions:[
                    TextButton(onPressed:(){
                    setState(() {
                      _hasLoaded = false;
                    });
                      deleteSchedule(schedule.id).then((x){
                        loadSchedules().then((x){
                          setState((){
                            _hasLoaded = true;
                          });
                        });
                      });
                       Navigator.of(context).pop();
                    },
                      child:const Text("Yes")
                    ),
                    TextButton(onPressed:() => Navigator.of(context).pop(),
                      child: const Text("No")
                    )
                  ]
                ));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("${schedule.course} $level-${schedule.block.replaceAll("Block ", "")} (${schedule.laboratory})",
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1.5, fontSize:18*scaleFactor, color: Colors.black),
                  )),
              ),
            ),
            ),
          )
        ]));
        }
      }
    }
    if(widgets.isEmpty){
      // widgets.add( SizedBox(height: 10.0*scaleFactor,));
    }
    return widgets;
  }


  List<Widget> weekDays(double scaleFactor){
    List<Widget> widgets = [];
    for (int i = 0; i <weekdays.length; i++){
      widgets.add(
       Column(
         children: [
           SizedBox(
              width:double.infinity,
              height: 60,
              child: DecoratedBox(decoration: BoxDecoration(color: dayColor,
              border: Border(bottom:BorderSide(width:1.0, color: dayColor))
              ),
                child: TextButton(
                  onPressed: (){
                    setState(() {
                      if(collapsed.contains(i)){
                          collapsed.remove(i);
                        }else{
                          collapsed.add(i);
                        }
                    });
                  },
                  child: Center(child: Text(weekdays[i], style: TextStyle(fontSize: 24*scaleFactor, 
                  color: Colors.white,
                  letterSpacing: 10.0, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
           
         ],
       ) );
      if(!collapsed.contains(i)){
        widgets.add(Column(
          children: showSchedule(weekdays[i],scaleFactor)
        ));
      }
      widgets.add( const SizedBox(
        width: double.infinity,
        height: 8.0,
        child:DecoratedBox(decoration:BoxDecoration(color:Color.fromARGB(221, 213, 227, 231)))
        ));

    } 
    widgets.add(SizedBox(height: 200*scaleFactor,));
     return widgets;
  }

  String timeFromPicker(TimeOfDay timePicker){
    var unit = "AM";
    var minute = timePicker.minute.toString();
    Object hour;
    if(timePicker.hour >= 12){
      unit = "PM";
      hour = timePicker.hour - 12;
    }else{
      hour = timePicker.hour;
    }
    if(hour == 0){
      hour = "12";
    }

    return "${hour.toString().padLeft(2,'0')}:${minute.toString().padLeft(2, '0')} $unit";
  }

  bool isValidTime(TimeOfDay? start, TimeOfDay? end){
    if(start== null || end== null) return false;
    return (((start.hour * 60 * 60)  + start.minute * 60) < ((end.hour * 60 * 60)  + end.minute * 60));
  }


  List<Widget> weeklyButtons(){
        List<Widget> widgets = [];
        for(int i = 0; i < weekdays.length ; i++){
          widgets.add(SizedBox(
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                ),
                child: Text(weekdays[i], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:(){
                  setState(() {
                    selectedDay = weekdays[i];
                  });
                  Navigator.of(context).pop();
                }),
            ));

          widgets.add(const SizedBox(height:20.0));
        }
        return widgets;
  }

  Future deleteSchedule(String id) async{
      var url = Uri.parse("${Connection.host}flutter_php/delete.php");
    var response = await server.post(url, body: {
      "id" : id,
      "from" : "student_schedules"
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print('error');
    }
  }

  List<DropdownMenuEntry<String>> filterEntries() {
      List<DropdownMenuEntry<String>>  entries = [];
      entries.add(const DropdownMenuEntry<String>(value: "Show all", label: "Show all"));
      for (var key in _laboratories.keys) {
            entries.add(DropdownMenuEntry<String>(value: _laboratories[key]!.id, label: key));
      }
    return entries;
  }

  // variable theme 
  Color dayColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height/1000;
    return WillPopScope(
      onWillPop: () async{
        Navigator.of(context).pop(widget.student);
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            appBar:appBar(scaleFactor, "MY SCHEDULES", context, _currentTab, null, widget.student, autoleading: true),
            body: (!_hasLoaded) ? Center(child:loader(scaleFactor)): Row(
              children: [
                Flexible(
                  child: Column(
                   children: [
                     simpleTitleHeader(scaleFactor, "COMPUTER LABORATORY SCHEDULES","Hold to remove schedules"),
                     Expanded(
                       child: Stack(
                         children: [
                           SingleChildScrollView(
                            child : Column(
                              children: weekDays(scaleFactor),)
                           ),
                           Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                  SizedBox(
                                      height: 60*scaleFactor,
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment : MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment : CrossAxisAlignment.center,
                                        children:[
                                        Flexible(
                                          flex: 2,
                                            child: Container(
                                              clipBehavior: Clip.antiAlias,
                                              height: double.infinity,
                                              decoration:BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                                border: Border.all(width:1.0)
                                              ),
                                              child: DropdownMenu(
                                                initialSelection: (_optionLabID!=null)? _optionLabID : null,
                                                  hintText: "Filter by Laboratory",
                                                  enabled: (_laboratories.isNotEmpty),
                                                    width: 250*scaleFactor,
                                                    textStyle: TextStyle(fontSize: 18*scaleFactor),
                                                    onSelected: (String? value){
                                                      if(value == "Show all"){
                                                        setState(()=>_optionLabID = null);
                                                      }else{
                                                        setState(()=>_optionLabID = value);
                                                      }
                                                      
                                                    },
                                                    dropdownMenuEntries:filterEntries(),
                                                  ),
                                            )
                                        
                                        ),
                                        Flexible(
                                          child: SizedBox(height: double.infinity,
                                            width: 100,
                                            child: Padding(
                                              padding:  EdgeInsets.symmetric(vertical: 0.0*scaleFactor),
                                              child: DecoratedBox(decoration:const BoxDecoration(color:Colors.orange,
                                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
        
                                              ),
                                              child: TextButton(  
                                                onPressed:(){
                                                setState(() {
                                                  startTime = null;
                                                  endTime = null;
                                                  selectedDay = null;
                                                });
                                        showDialog(context:context, builder:(context)=>
                                            SimpleDialog( 
                                              alignment: Alignment.center,
                                              backgroundColor: Colors.transparent,
                                              children:
                                                  weeklyButtons()
                                            )
                                          ).then((x){
                                              if(selectedDay == null) return;
                              
                                             
                                              showDialog(context: context, builder: (context) => StatefulBuilder(
                                                builder: (context,setState) {
                                                  return AlertDialog(
                                                    contentPadding: EdgeInsets.zero,
                                                    clipBehavior: Clip.antiAlias,
                                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                    content: SizedBox(
                                                      width: 500*scaleFactor,
                                                      height: 450*scaleFactor,
                                                      child: Column(
                                                              children: [
                                                                const SizedBox(width: double.infinity,
                                                                  height: 60.0,
                                                                  child: DecoratedBox(decoration: BoxDecoration(color: Colors.blue),
                                                            
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(Icons.calendar_month, color:Colors.white),
                                                                          SizedBox(width: 10),
                                                                          Text("Add new schedule",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                
                                                          Expanded(
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric( vertical: 15.0, horizontal:5.0),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.all(5.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                DropdownMenu(
                                                                  enabled: (_laboratories.isNotEmpty),
                                                                  initialSelection: (_optionLabID != null) ? _optionLabID: null,
                                                                  hintText: "Choose Laboratory",
                                                                  textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                                    width: 320*scaleFactor,
                                                                    onSelected: (String? value){ 
                                                                      setState((){
                                                                        _optionLabID = value;
                                                                      });
                                                                    },
                                                                    dropdownMenuEntries: _laboratories.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                                      return DropdownMenuEntry<String>(value: _laboratories[item]!.id, label: item);
                                                                    }).toList(),
                                                                  )
                                                              ],),
                                                            ),
                                                          
                                                      
                                                                const SizedBox(height:15.0),
                                                        Padding(padding:const EdgeInsets.all(8.0),
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                              Flexible(
                                                                child: SizedBox(
                                                                  height: 35.0 * scaleFactor,
                                                                  child:Text( (startTime!= null)? timeFromPicker(startTime!): "00:00 AM")),
                                                              ),
                                                                const SizedBox(width:10),
                                                              Flexible(
                                                                child: SizedBox(
                                                                  height: 35.0 * scaleFactor,
                                                                  child:const Text(" - ")),
                                                              ),
                                                              const SizedBox(width:10),
                                                              Flexible(
                                                                child: SizedBox(
                                                                  height: 35.0 * scaleFactor,
                                                                  child:Text((endTime != null) ? timeFromPicker(endTime!) : "00:00 AM")),
                                                              ),
                                                                ],),
                                                              ),
                                                      Padding(padding:const EdgeInsets.all(8.0),
                                                          child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                              Flexible(
                                                                child: SizedBox(
                                                                  height: 35.0,
                                                                  child:ElevatedButton(onPressed: ()async{
                                                                    TimeOfDay initialTime = (startTime!=null) ? startTime! : const TimeOfDay(hour: 8, minute:0);
                                                                    var selectedTime = await showTimePicker(context: context, initialTime: initialTime);
                                                                    setState((){
                                                                      if(selectedTime!=null) startTime = selectedTime;
                                                                    });
                                                                  },
                                                                    style: ElevatedButton.styleFrom(backgroundColor: isValidTime(startTime, endTime) ? Colors.green: Colors.deepOrange, 
                                                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))  
                                                                  ), child: const Text("Set Start Time"),
                                                                  )),
                                                              ),
                                                              const SizedBox(width:10),
                                                              Flexible(
                                                                child: SizedBox(
                                                                  height: 35.0,
                                                                    child:ElevatedButton(onPressed: ()async{
                                                                      TimeOfDay initialTime = (endTime!=null) ? endTime! : const TimeOfDay(hour: 8, minute:0);
                                                                      var selectedTime = await showTimePicker(context: context, initialTime: initialTime);
                                                                      setState((){
                                                                        if(selectedTime!=null) endTime = selectedTime;
                                                                      });
                                                                  },
                                                                    style: ElevatedButton.styleFrom(backgroundColor:  isValidTime(startTime, endTime)  ?  Colors.green: Colors.deepOrange, 
                                                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))  
                                                                  ), child: const Text("Set End Time"),
                                                                  )),
                                                              ),
                                                                ],),
                                                              ),
                                                              ],)
                                                            ),
                                                            ),
                                                    ),
                                                    SizedBox(
                                                      width: double.infinity ,
                                                      height: 60*scaleFactor,
                                                      child: DecoratedBox(decoration: const BoxDecoration(color: Colors.orange),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                                          children: [
                                                        Expanded(child: TextButton(child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),onPressed: ()=>{
                                                          Navigator.of(context).pop()},)),
                                                        Expanded(child: TextButton(child: Text((_hasLoaded) ? "ADD" : "ADDING", style: TextStyle(color: (!isValidTime(startTime, endTime) || !_hasLoaded) ? Colors.grey:Colors.white, fontWeight: FontWeight.bold)),
                                                        onPressed: (){
                                                          if(isValidTime(startTime, endTime) && _hasLoaded ){
                                                            setState((){
                                                              _hasLoaded = false;
                                                                if(collapsed.contains( weekdays.indexOf(selectedDay!.toUpperCase()))){
                                                                  collapsed.remove( weekdays.indexOf(selectedDay!.toUpperCase()));
                                                                }
                                                              
                                                            });
                            
                                                            if(widget.student.block == null){
                                                              showError(context, 'Please specify your block in your profile');
                                                              setState(() {
                                                                _hasLoaded = true;
                                                              });
                                                              return;
                                                            }
                                                            addSchedule().then((x){
                                                                loadSchedules().then((x){
                                                                  setState(() {
                                                                    _hasLoaded = true;
                                                                  });
                                                                  Navigator.of(context).pop();  
                                                                });
                                                        
                                                            } 
                                                          );
                                                            
                                                      
                                                          
                                                          }
                                                        },))
                                                      ],)
                                                      )
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        ));
                                                });
                                                },
                                                child: const Center( child: Icon(Icons.add, color: Colors.white))),
                                              
                                              ),
                                            )
                                          ),
                                        )
                                    ])
                                  ),
                                  SizedBox(
                                    height: 50*scaleFactor,
                                  )
                        ],),
                         ],
                       ),
                     ),
                   ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}