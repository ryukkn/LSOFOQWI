import 'dart:convert';

import 'package:bupolangui/components/custombuttons.dart';
import 'package:bupolangui/components/preloader.dart';
import 'package:bupolangui/components/selectors.dart';
import 'package:bupolangui/constants/constants.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/models/course.dart';
import 'package:bupolangui/models/device.dart';
import 'package:bupolangui/models/faculty.dart';
import 'package:bupolangui/models/laboratory.dart';
import 'package:bupolangui/models/report.dart';
import 'package:bupolangui/components/popups.dart';
import 'package:bupolangui/models/schedule.dart';
import 'package:bupolangui/models/session.dart';
import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:bupolangui/pages/qrscanner.dart';
import 'package:bupolangui/pages/viewprofile.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as server;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:bupolangui/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


 void scheduleAlarm(Schedule schedule) async {
 
    List<String> weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY","FRIDAY", "SATURDAY"];
    DateTime scheduledNotificationDateTime = DateTime.now();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'Ongoing Class',
      'Ongoing Class',
      channelDescription: 'Channel for Alarm notification',
      icon: '@mipmap/logo',
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
      await flutterLocalNotificationsPlugin.zonedSchedule(0, "You have a class in ${getShortCourse(schedule)}", schedule.time, tz.TZDateTime.now(tz.local).add(
        Duration(days: days, seconds: seconds)),
         platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  
  }



class FacultyHome extends StatefulWidget {
  final Faculty faculty;
  const FacultyHome({super.key, required this.faculty});

  @override
  State<FacultyHome> createState() => _FacultyHomeState();
}


class _FacultyHomeState extends State<FacultyHome> {

  List<Course> assignedCourses = [];
  Map<String,List<Schedule>> _schedules = {};
  
  bool hasLoaded = false;
  Schedule? _nextSchedule;
  String _schedStatus = "NEXT";
  List<String> weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY","FRIDAY", "SATURDAY"];

  Timer? timer;
  Timer? animationTimer;

  List<Color> alternatingOranges = [Colors.orange.shade400,Colors.orange.shade900,];
  List<Color> alternatingBlues =[
              Colors.blue.shade900,
              Colors.lightBlue];

  List<double> alternatingVerticalPadding = [-3.0, 3.0];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tz.initializeTimeZones();
    alternatingOranges = alternatingOranges.reversed.toList();
    alternatingBlues = alternatingBlues.reversed.toList();
    alternatingVerticalPadding = alternatingVerticalPadding.reversed.toList();
    loadCourses().then((x) => loadSchedules().then((x) => {
      if(mounted)setState((){
        getNextSchedule();
        timer = Timer.periodic(const Duration(seconds:1) , (timer)=>setState((){
            getNextSchedule();
          })
        );
        animationTimer = Timer.periodic(const Duration(seconds:4) , (animationTimer)=>setState((){
            alternatingOranges = alternatingOranges.reversed.toList();
            alternatingBlues = alternatingBlues.reversed.toList();
             alternatingVerticalPadding = alternatingVerticalPadding.reversed.toList();
        }));
        hasLoaded = true;
      })
    }));

  }
  @override
  void dispose(){
    super.dispose();
    if(timer!=null){
      timer!.cancel();
    }
    if(animationTimer!=null){
      animationTimer!.cancel();
    }
  }

  Future loadSchedules()async{
      var url = Uri.parse("${Connection.host}flutter_php/faculty_getschedules.php");
      var response = await server.post(url, body: {
        'id': widget.faculty.id,
      });

      var data= json.decode(response.body);
      if(data['success']){
        var rows=  data['rows'];
        Map<String, List<Schedule>> schedules= {};
        rows.forEach((row){
          if(!schedules.containsKey(row['day'].toString().toUpperCase())){
              schedules[row['day'].toString().toUpperCase()] = [];
          }
          schedules[row['day'].toString().toUpperCase()]!.add(decodeSchedule(row));
        }); 
        if(mounted){
          setState(() {
              _schedules = schedules;
          });
        }
      }
  }
  
  Future loadCourses() async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_loadcourses.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });
    var data = json.decode(response.body);
    if(data["success"]){
      List<Course> courses = []; 
      List<String> courseLabels = [];
      data['rows'].forEach((row){
          courses.add(
            decodeCourse(row)
          );
          if(!courseLabels.contains(row['course'])){
            courseLabels.add(row['course']);
          }
      });
      if(mounted){
        setState(() {
          assignedCourses = courses;
        });
      }
    }
  }

  void getNextSchedule(){
    String day = DateFormat('EEEE').format(DateTime.now());
    DateTime currentTime = DateTime.now();
    Schedule? nextSchedule;
    String schedStatus = "NEXT";

    if(_schedules.keys.contains(weekdays.indexOf(day.toUpperCase()).toString())){
      for (var schedule in _schedules[weekdays.indexOf(day.toUpperCase()).toString()]!) {
          if(nextSchedule==null){
            var endCurrent = DateFormat("hh:mm a").parse(schedule.time.split(" - ")[1]);

            int secondsToEnd = ((endCurrent.hour * 60 * 60) + endCurrent.minute *60)
              - ((currentTime.hour * 60 * 60) + currentTime.minute *60 );
   
            // currentHour = (currentHour == 24) ? 0 : currentHour;
           
            if( secondsToEnd > 0){
               nextSchedule = schedule;
            }
          }else{
            // check if date is smaller than last schedule
             var startCurrent = DateFormat("hh:mm a").parse(schedule.time.split(" - ")[0]);
             var endCurrent = DateFormat("hh:mm a").parse(schedule.time.split(" - ")[1]);
             var startPrev = DateFormat("hh:mm a").parse(nextSchedule.time.split(" - ")[0]);

             int secondsToEnd = ((endCurrent.hour * 60 * 60) + endCurrent.minute *60)
              - ((currentTime.hour * 60 * 60) + currentTime.minute *60 );
              int secondsTarget = ((startCurrent.hour * 60 * 60) + startCurrent.minute *60)
              - ((startPrev.hour * 60 * 60) + startPrev.minute *60 );

            if(secondsToEnd > 0 && 
              secondsTarget < 0
            ){
              nextSchedule = schedule;
            }
          }
      }
    }
    if(nextSchedule!=null){
        var start = DateFormat("hh:mm a").parse(nextSchedule.time.split(" - ")[0]);
        int seconds = ((start.hour * 60 * 60) + start.minute *60)
              - ((currentTime.hour * 60 * 60) + currentTime.minute *60 );
        if( seconds <= 0 ){
          schedStatus = "NOW";
        }
    }
  
    setState((){  
      _schedStatus = schedStatus;
      _nextSchedule = nextSchedule;
    });
  }


  List<Widget> showCourses(){
    List<Widget> widgets = [];
    List<String> takenCourses = [];
    for (var course in assignedCourses) {
      if(!takenCourses.contains(course.course)){
        takenCourses.add(course.course);
        widgets.add(   
        Container(
          height:double.infinity,
            width:180,
            child:AnimatedPadding(
              duration: const Duration(seconds:4), 
              padding: EdgeInsets.only(top:15.0+alternatingVerticalPadding[0], bottom:15.0+alternatingVerticalPadding[1],left:15.0,right:15.0),
              child: AnimatedContainer(
               duration: const Duration(seconds:4), 
                decoration: BoxDecoration( gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: const Alignment(0.8, 1),
            colors: alternatingBlues,
            tileMode: TileMode.mirror,
          ),
                borderRadius: const BorderRadius.all(Radius.circular(15.0))
              ),
                    child:TextButton(
                      onPressed:(){
                        Navigator.pushReplacement(
                          context,
                        PageRouteBuilder(
                            pageBuilder: (context , anim1, anim2) =>
                                FacultyManageCourse(faculty: widget.faculty,course: course)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(parseAcronym(course.course) , style: const TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                          Text(course.course, 
                            textAlign: TextAlign.center,
                            style: const TextStyle(color:Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
                        ],
                      ),
                    )
              ),
            ))
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return WillPopScope(
       onWillPop: ()async{
        return false;
      },
      child: Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body:  Column(
            children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: [
                        SizedBox(height: 300,
                          width:double.infinity,
                          child:DecoratedBox(decoration: BoxDecoration(
                                color:const Color.fromARGB(255, 34, 28, 22),
                                // color: Colors.blue.shade900,
                                 gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Colors.blue.shade900,
                                                Colors.black
                                      
                                              ],
                                              tileMode: TileMode.mirror,
                                            ),
                                image: DecorationImage(
                                    image: const AssetImage(
                                        'assets/images/bupcbg.jpg'),
                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                                    fit: BoxFit.cover,
                                  ),
                              ),
                                child: Column(children:[
                              SizedBox(height: MediaQuery.of(context).padding.top,),
                                SizedBox(height: 60 ,
                                    width:double.infinity,
                                    child:DecoratedBox(decoration: const BoxDecoration(color:Colors.transparent),
                                      child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          SizedBox(width: 60 ,
                                             child: InkWell(
                                                      onTap: ()=>{
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
                                                                child: const Text("PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:(){
                                                                  Navigator.push(
                                                                      context,
                                                                    PageRouteBuilder(
                                                                        pageBuilder: (context , anim1, anim2) =>
                                                                            ViewProfile(account: widget.faculty,)));
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
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                      PageRouteBuilder(
                                                                          pageBuilder: (context , anim1, anim2) =>
                                                                              const LandingPage()));
                                                                  }),
                                                              ),
                                                            ]
                                                          )
                                                        )
                                                      },
                                                      child: const Icon(Icons.menu, color:Colors.white),
                                                    ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top:15.0, left:10.0, right:10.0, bottom:10.0),
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color:Colors.white.withOpacity(0.3),
                                                  borderRadius: const BorderRadius.all(Radius.circular(15.0))
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                              style: const TextStyle(color:Colors.white),
                                                            decoration:const InputDecoration(
                                                              contentPadding: EdgeInsets.only(
                                                                left:15.0,
                                                                bottom: 10.0,  
                                                              ),
                                                               border: InputBorder.none
                                                            ),
                                                          ),
                                                      ),
                                                      SizedBox(width: 40.0,
                                                        child: InkWell(onTap:(){},
                                                          child:const Icon(Icons.search)
                                  
                                                      ))
                                                    ],
                                                  ),
                                                  
                                                ),
                                              ),
                                            )
                                          )
                                          
                                      ])
                                    )
                                  ),
                                  Expanded(
                                child:Center(
                                  child:
                                  SizedBox(
                                    width: 120.0 ,
                                    height: 120.0,
                                    child: Image.asset('assets/images/bupolanguiseal.png',
                                      isAntiAlias: true,
                                    )
                                  ),
                              )),
                    
                            ]),
                          )
                        ),
                         Padding(
                            padding: const EdgeInsets.only(left:0.0, right: 25),
                            child: SizedBox(
                              width:double.infinity,
                              height: 65,
                              child:DecoratedBox(decoration:BoxDecoration(color: Colors.blue.shade600,
                              gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: const Alignment(0.8, 0.5),
                                              colors: <Color>[
                                                Colors.blue.shade900,
                                                Colors.blue.shade600
                                      
                                              ],
                                              tileMode: TileMode.mirror,
                                            ),
                                borderRadius : const BorderRadius.only(
                                  bottomLeft : Radius.circular(100.0),
                                  topRight : Radius.circular(100.0),
                                )
                              ),
                                child: Column(
                                  mainAxisAlignment : MainAxisAlignment.spaceEvenly,
                                  children:[
                                  const Text("WELCOME,", style:TextStyle(fontWeight: FontWeight.bold,
                                    letterSpacing:1.2,
                                    fontSize:16,
                                    color:Colors.white
                                  )),
                                  Text(widget.faculty.fullname.toUpperCase(),
                                  style:const TextStyle(fontWeight: FontWeight.bold,
                                    letterSpacing:1.5,
                                    fontSize:18,
                                    color:Colors.white
                                  )),
                                ]) ,
                              )),
                          ),
                         SizedBox(
                            height: 220.0,
                            width:double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: AnimatedContainer(
                                duration: const Duration(seconds:4),
                                clipBehavior: Clip.antiAlias,
                                decoration:BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                  gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: const Alignment(0.8, 0.5),
                                              colors: alternatingOranges,
                                              tileMode: TileMode.mirror,
                                            ), ),
                                child:Column(
                                  children:[
                                    Expanded(child:SizedBox(width:double.infinity ,
                                      child: (assignedCourses.isEmpty) ?
                                      Center(child: Text((!hasLoaded) ? "LOADING" :"EMPTY", style: const TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),)
                                       :Stack(
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal ,
                                            child: Row(
                                              children:showCourses()),
                                          ),
                                          const Align(alignment:Alignment.centerRight,
                                            child: SizedBox(height:double.infinity, width : 300)
                                          )
                                        ],
                                      )
                                    )),
                                    SizedBox(height: 50, width: double.infinity,
                                      child: DecoratedBox(
                                        decoration: const BoxDecoration(color:Colors.blue),
                                        child: Row(
                                          children: [
                                            const SizedBox(width:15),
                                            const Icon(Icons.collections_bookmark, color:Colors.white),
                                            const SizedBox(width:10),
                                            const Expanded(child: Text("MY COURSES", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold))),
                                            SizedBox(width: 90, height: double.infinity,
                                                child: TextButton(onPressed:(){
                                                    Navigator.pushReplacement(
                                                          context,
                                                        PageRouteBuilder(
                                                            pageBuilder: (context , anim1, anim2) =>
                                                                FacultyManageCourse( faculty: widget.faculty,)));
                                                }, child:const Row(
                                                  children: [
                                                    Text("View all", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold)),
                                                    Icon(Icons.arrow_right, color:Colors.white)
                                                  ],
                                                ),)
                                              ),
                                            
                                          ],
                                        ),
                                      )
                                    ),
                                  
                                ])
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            height:200.0,
                             width:double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                 clipBehavior: Clip.antiAlias,
                                decoration:const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  color:Color.fromARGB(255, 205, 222, 233)),
                                  child:Column(
                                  children:[
                                    Expanded(child:SizedBox(width:double.infinity,
                                      child:Row(children:[
                                        AnimatedContainer(
                                          duration: const Duration(seconds:4),
                                          width:150,
                                          height:double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: const Alignment(0.8, 1),
                                              colors: alternatingOranges,
                                              tileMode: TileMode.mirror,
                                            ), 
                                            color:Colors.deepOrange,

                                          ),
                                          child:Center(child: Text(_schedStatus,style:const TextStyle(color:Colors.white, fontWeight:FontWeight.bold,
                                            fontSize: 28,
                                          )))
                                        ),
                                        Expanded(
                                          child: Container(
                                         
                                            height:double.infinity,
                                            decoration:BoxDecoration(
                                            color:Colors.lightBlue.shade300,
                                          ),
                                          child:AnimatedPadding(
                                            duration: const Duration(seconds:4),
                                              padding: EdgeInsets.only(top:15 + alternatingVerticalPadding[0], right:15, bottom:15+alternatingVerticalPadding[1],left:15),
                                              child: AnimatedContainer(
                                                duration: const Duration(seconds:4),
                                            decoration: BoxDecoration( gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: const Alignment(0.8, 1),
                                            colors:alternatingBlues,
                                            tileMode: TileMode.mirror,
                                          ),
                                                borderRadius: const BorderRadius.all(Radius.circular(15.0))
                                              ),
                                                    child:TextButton(
                                                      onPressed:(){
                                                        Navigator.pushReplacement(
                                                          context,
                                                        PageRouteBuilder(
                                                            pageBuilder: (context , anim1, anim2) =>
                                                                TimeIn(faculty: widget.faculty,schedule: _nextSchedule)));
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text((_nextSchedule!=null) ? getShortCourse(_nextSchedule!) : "NONE"  , style: const TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                                                          Text( (_nextSchedule!=null) ? _nextSchedule!.time: "No more schedules for today.", 
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(color:Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
                                                        ],
                                                      ),
                                                    )
                                              ),
                                            )
                                          
                                          ),
                                        )
                                      ])
                                      
                                    )),
                                    SizedBox(height: 40, width: double.infinity,
                                      child: DecoratedBox(
                                        decoration: const BoxDecoration(color:Colors.blue),
                                        child: Row(
                                          children: [
                                            const SizedBox(width:15),
                                            const Icon(Icons.next_plan, color:Colors.white),
                                            const SizedBox(width:10),
                                            const Expanded(child: Text("NEXT SCHEDULE", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold))),
                            
                                             SizedBox(width: 90, height: double.infinity,
                                                child: TextButton(onPressed:(){
                                                    Navigator.pushReplacement(
                                                          context,
                                                        PageRouteBuilder(
                                                            pageBuilder: (context , anim1, anim2) =>
                                                                FacultyScheduling( faculty: widget.faculty,)));
                                                }, child:const Row(
                                                  children: [
                                                    Text("View all", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold,)),
                                                    Icon(Icons.arrow_right, color:Colors.white)
                                                  ],
                                                ),)
                                              ),
                                            
                                          ],
                                        ),
                                      )
                                    ),
                                  
                                ])
                              ),
                            ),
                          ),
                          SizedBox(height: 90*scaleFactor)
                    ]),
                  ),
                ),
              
            ],
          )
        ),
          // Create Bottom  Navigation Bar
         bottomNavigation(scaleFactor, context, widget.faculty, 1)
      ],),
    );
  }
}

class Evaluation extends StatefulWidget {
  final Student? student;
  final Device? device;
  final Session? session;
  final Faculty faculty;
  final String screen;
  const Evaluation({super.key, required this.student, required this.device, this.session,required this.faculty,required this.screen});

  @override
  State<Evaluation> createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
  final TextEditingController _remarkController = TextEditingController();
  TextEditingController systemUnit =TextEditingController();
  TextEditingController monitor =TextEditingController();
  TextEditingController mouse =TextEditingController();
  TextEditingController keyboard =TextEditingController();
  TextEditingController avrups =TextEditingController();
  TextEditingController wifidongle =TextEditingController();

  bool submitting = false;

  Future submitSession() async{
    setState(() {
      submitting = true;
    });
    var url = Uri.parse("${Connection.host}flutter_php/faculty_submitsession.php");
    var response = await server.post(url, body: {
      "studentID": widget.student!.id,
      "facultyID": widget.faculty.id,
      "deviceID" : widget.device!.id,
      "systemUnit": systemUnit.text,
      "monitor" : monitor.text,
      "mouse" : mouse.text,
      "keyboard" : keyboard.text,
      "avrups" : avrups.text,
      "wifidongle" : wifidongle.text,
      "remarks" : _remarkController.text
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print("error");
    }
    setState(() {
      submitting = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
        if(widget.session!=null){
          systemUnit.text = widget.session!.systemUnit!;
          monitor.text = widget.session!.monitor!;
          mouse.text = widget.session!.mouse!;
          keyboard.text = widget.session!.keyboard!;
          avrups.text = widget.session!.avrups!;
          wifidongle.text = widget.session!.wifidongle!;
          _remarkController.text = widget.session!.remarks!;
        }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    systemUnit.dispose();
    monitor.dispose();
    keyboard.dispose();
    mouse.dispose();
    avrups.dispose();
    wifidongle.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return WillPopScope(
      onWillPop: ()async{
                 switch(widget.screen){
                  case "Manage Course":
                   Navigator.pushReplacement(
                      context,
                    PageRouteBuilder(
                        pageBuilder: (context , anim1, anim2) =>
                            FacultyManageCourse( faculty: widget.faculty,)));
                  break;
                  default:
                   Navigator.pushReplacement(
                      context,
                    PageRouteBuilder(
                        pageBuilder: (context , anim1, anim2) =>
                            TimeIn( faculty: widget.faculty,)));
                    break;
                 }
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: appBar(scaleFactor, "TIME IN", context, 1, (){
                switch(widget.screen){
                          case "Manage Course":
                          Navigator.pushReplacement(
                              context,
                            PageRouteBuilder(
                                pageBuilder: (context , anim1, anim2) =>
                                    FacultyManageCourse( faculty: widget.faculty,)));
                          break;
                          default:
                          Navigator.pushReplacement(
                              context,
                            PageRouteBuilder(
                                pageBuilder: (context , anim1, anim2) =>
                                    TimeIn( faculty: widget.faculty,)));
                            break;
                        }
            }, widget.faculty),
            body: (widget.student != null && widget.device != null) ? ListView(
              controller: ScrollController(),
              children: [
              SizedBox(
                width: double.infinity,
                height: 25*scaleFactor,
                child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
              ),
              SizedBox(
                width: double.infinity,
                height:110*scaleFactor,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 35*scaleFactor,
                            child: DecoratedBox(decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              child:  Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 8.0, vertical: 0.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.computer, size: 32 *scaleFactor,),
                                      SizedBox(width: 15 * scaleFactor,),
                                      Text(widget.device!.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21*scaleFactor),),
                                    ],
                                  )),
                              ),
                            )),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.0),
                          child: SizedBox(height: 3.0, width: 200,
                            child: DecoratedBox(decoration: BoxDecoration(color: Colors.black87),),
                          ),
                        ),
    
                       Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 35*scaleFactor,
                            child: DecoratedBox(decoration: const BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              child:  Padding(
                                padding: const EdgeInsets.symmetric( horizontal: 8.0, vertical: 0.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person, size: 32 *scaleFactor,),
                                      SizedBox(width: 15 * scaleFactor,),
                                      Text(widget.student!.fullname.toUpperCase(), style: TextStyle(height: 1.2,letterSpacing: 0.5,fontWeight: FontWeight.bold, fontSize: 21*scaleFactor),),
                                    ],
                                  )),
                              ),
                            )),
                        ),
                        
                      ]),
                    ),
                  ),
                ),
                 SizedBox(
                  width: double.infinity,
                  height: 20*scaleFactor,
                  child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                ),
                SizedBox(
                width: double.infinity,
                height: 120*scaleFactor,
                child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 200, 238, 255)),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                      TextSpan(text: "CURRENT STATUS OF PC/LAPTOP\n", style: TextStyle(height: 1,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                      TextSpan(text: "INSTRUCTIONS:\n", style: TextStyle(height: 2.0, letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black,fontWeight: FontWeight.w600)),
                      TextSpan(text: "Choose the current status of the components of PC/Laptop.\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
                      TextSpan(text: "Required", style: TextStyle(height: 1.5,letterSpacing: 1.0, color: Colors.black,  fontSize: 14*scaleFactor)),
                      TextSpan(text: " *", style: TextStyle(height: 1.5,letterSpacing: 1.0, color: Colors.red,  fontSize: 14*scaleFactor))
                    ])),
                  ),
                ),
              ),
               SizedBox(
                  width: double.infinity,
                  height: 20*scaleFactor,
                  child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 10*scaleFactor,
                ),
              Column(
                  children: [
                    EvaluationSelector(defaultValue: systemUnit, title: "SYSTEM UNIT", icon: Icons.ad_units,callback: ()=>setState(()=>{}),),
                    EvaluationSelector(defaultValue: monitor, title: "MONITOR", icon: Icons.monitor,callback: ()=>setState(()=>{})),
                    EvaluationSelector(defaultValue: mouse, title: "MOUSE", icon: Icons.mouse,callback: ()=>setState(()=>{})),
                    EvaluationSelector(defaultValue: keyboard, title: "KEYBOARD", icon: Icons.keyboard,callback: ()=>setState(()=>{})),
                    EvaluationSelector(defaultValue: avrups, title: "AVR / UPS", icon: Icons.power,callback: ()=>setState(()=>{})),
                    EvaluationSelector(defaultValue: wifidongle, title: "WI-FI DONGLE", icon: Icons.wifi,callback: ()=>setState(()=>{}))
                  ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(height: 100*scaleFactor,width: double.infinity,
                    child: TextFormField(
                      maxLines: 5,
                      scrollPadding: EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom + 90*scaleFactor),
                      controller: _remarkController,
                      style: TextStyle(
                                    fontSize: 18  * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    ),
                      decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        labelText: "Remarks",
                        alignLabelWithHint: true,
                      ),
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: SizedBox(height: 50*scaleFactor, width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: (!(systemUnit.text == "" || monitor.text == "" || avrups.text == "" 
                        || wifidongle.text == "" || keyboard.text == "" || mouse.text == "" ) && !submitting) ? Colors.orange : Colors.grey , shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))),
                    child: Text((submitting)? 'LOADING' :'SAVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 20*scaleFactor),), onPressed: (){
                       if(!(systemUnit.text == "" || monitor.text == "" || avrups.text == "" 
                        || wifidongle.text == "" || keyboard.text == "" || mouse.text == "")){
                          if(!submitting){
                            submitSession();
                            Navigator.pushReplacement(
                                  context,
                                PageRouteBuilder(
                                    pageBuilder: (context , anim1, anim2) =>
                                      TimeIn( faculty: widget.faculty,)));
                          }
                        }
                    },),
                )),
              ),
              Padding(
                padding: EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
                child: SizedBox(height: 90*scaleFactor,),
              )
            ]):  const Center(
            child: Text("404 : Not Found"),
          ),
          ),
          // Create Bottom  Navigation Bar
         bottomNavigation(scaleFactor, context, widget.faculty,4)
        ],
      ),
    );
  }
}


// ignore: must_be_immutable
class TimeIn extends StatefulWidget {
  Faculty faculty;
  Schedule? schedule;
  TimeIn({super.key, required this.faculty, this.schedule});

  @override
  State<TimeIn> createState() => _TimeInState();
}

class _TimeInState extends State<TimeIn> {

  bool hasLoaded = false;
  bool active_session = false;
  bool timed_in = false;

  int currentTab = 0;

  Timer? timer;

  
  List<String> courses = [];
  List<String> levels = [];
  Map<String, String> blocks = {};
  Map<String,String> laboratories = {};

  List<Course> assignedCourses = [];
  List<Laboratory> availableLabs = [];

  String? course;
  String? level;
  String? block;
  String? lab;
  Report? report;
  

    TextEditingController levelController = TextEditingController();
      TextEditingController blockController = TextEditingController();
      TextEditingController dateController = TextEditingController();
      TextEditingController timeController = TextEditingController();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    levelController.dispose();
    blockController.dispose();
    dateController.dispose();
    timeController.dispose();
    if(timer!=null){
      timer!.cancel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // check if facullty has active_session
    checkActiveClass().then((x){
      loadLaboratories().then((x)=>{
        loadCourses().then((x){
          if(mounted){
            dateController.text = getDate();
            timeController.text = getTime();
            timer = Timer.periodic(const Duration(seconds:1), (timer){
                dateController.text = getDate();
                timeController.text = getTime();
              }
            );
            if(widget.schedule!=null){
              Course? selectedClass;
              for (var course_ in assignedCourses) {
                if(course_.id == widget.schedule!.blockID){
                  selectedClass =course_;
                  continue;
                }
              }
              if(selectedClass != null){
                loadLevels(selectedClass.course);
            
                 setState((){
                  course = selectedClass!.course;
                  level = selectedClass.year;
              
                  lab = widget.schedule!.labID;
                });
                loadBlocks(selectedClass.year);
                setState((){
                      block = selectedClass!.block;
                });
              }
             
            }
            setState(() {
              hasLoaded =true;
            });
          }
        })
      });
     
    });
    
  }


  Future checkActiveClass() async{
     var url = Uri.parse("${Connection.host}flutter_php/faculty_checkactiveclass.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });
    var data = json.decode(response.body);
    if(data["success"]){
      if(data["active"]){
        if(mounted){
          setState(() {
            report = decodeReport(data['row']);
            active_session = true;
          });
        }
      }
    }
  }

  
  bool startingClass = false;
  void startClass() async {
    setState(()=>startingClass = true);
    // get course id
    var courseId = "";
    for (var _course in assignedCourses) {
      if(_course.course == course && _course.year == level && _course.block == block){
        courseId = _course.id;
        break;
      }
    }
    var url = Uri.parse("${Connection.host}flutter_php/faculty_startclass.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
      "course_id": courseId,
      "labID":lab,
    });
    var data = json.decode(response.body);
    if(!data["success"]){
      print("error");
    }
     if(mounted){
       setState(() => active_session = true);
       setState(()=>startingClass = false);
     }
  }

  Future endClass() async {
    var url = Uri.parse("${Connection.host}flutter_php/faculty_endclass.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });
    var data = json.decode(response.body);
    if(!data["success"]){
      print("error");
    }
  }

  Future loadLaboratories() async{
      var url = Uri.parse("${Connection.host}flutter_php/getLabs.php");
      var response = await server.get(url);
      var data = json.decode(response.body);

      if(data['success']){
        var rows = data['rows'];
        Map<String,String> laboratories = {};
        List<Laboratory> loadedLabs = [];
        rows.forEach((dynamic row) {
          loadedLabs.add(decodeLaboratory(row));
          laboratories[parseAcronym(row['laboratory'])] = row['ID'];
        });
        if(mounted){
          setState(() {
            availableLabs = loadedLabs;
            this.laboratories = laboratories;
          });
        }
      }else{
        print(data['message']);
      }
  }

  Future loadCourses() async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_loadcourses.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });
    var data = json.decode(response.body);
    if(data["success"]){
      List<Course> courses = []; 
      List<String> courseLabels = [];
      data['rows'].forEach((row){
          courses.add(
            decodeCourse(row)
          );
          if(!courseLabels.contains(row['course'])){
            courseLabels.add(row['course']);
          }
      });
      if(mounted){
        setState(() {
          assignedCourses = courses;
          this.courses = courseLabels;
          course = null;
          level = null;
          block = null;
          levels = [];
          blocks = {};
        });
      }
    }
  }

  void loadLevels(String selectedCourse){
    List<String> levels = [];
    assignedCourses.forEach((course)=>{
      if(course.course == selectedCourse){
        if(!levels.contains(course.year)){
          levels.add(course.year)
        }
      }
    });
    levelController.text = "";
      blockController.text = "";
   if(mounted){
     setState(() {
        this.levels = levels; 
        level = null;
        block = null;
        blocks ={};
      });
   }
  }

   void loadBlocks(String selectedYear){
    Map<String, String> blocks = {};
    assignedCourses.forEach((course)=>{
      if(course.course == this.course && course.year == selectedYear){
        if(!blocks.containsKey(course.block)){
            blocks[course.block] = course.id
          }
      }
    });
    blockController.text = "";
   if(mounted){
     setState(() {
      block = null;
      this.blocks = blocks; 
    });
   }
  }

  void generateQR() async{
     var url = Uri.parse("${Connection.host}flutter_php/faculty_generateQR.php");
    var response = await server.post(url, body: {
      "id": blocks[block],
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print('error');
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds:500),
          content: Text('QR Code Generated')),
      );
    }
  }

  String getDate(){
    return DateFormat('MMM d, yyyy (EEEE)').format(DateTime.now());
  }

  String getTime(){
    return DateFormat.jm().format(DateTime.now());
  }


  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return  WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              title: Text("TIME IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,letterSpacing: 1.5, fontSize: 20*scaleFactor),),
              centerTitle: true,
              actions: [
                SizedBox(
                  width: 80.0*scaleFactor,
                  child: InkWell(
                    onTap: () =>{
                     if(active_session){
                      showDialog(context: context, builder: (context) => AlertDialog( 
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        title: const Text("Are you sure you want to end class and submit forms to the admin?"),
                        actions: [
                          TextButton(child: const Text("Yes"),
                            onPressed: (){
                              popUpMessage(context, "Please Wait");
                               endClass().then((value)
                                              {     
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                Navigator.pushReplacement(
                                                    context,
                                                  PageRouteBuilder(
                                                      pageBuilder: (context , anim1, anim2) =>
                                                          FacultyHome(faculty: widget.faculty,)));
                                              });
                            }
                          ),
                           TextButton(child: const Text("No"),
                              onPressed: ()=>{
                                    Navigator.of(context).pop()
                              }
                            ),
                          
                        ],
                       ))
                     }
                    },
                    child: Icon(Icons.exit_to_app_sharp, color: (active_session) ? Colors.white : Colors.grey),
                  ),
                )
              ],
              automaticallyImplyLeading: false,
            ),
            body:  (!hasLoaded) ? Center(child:loader(scaleFactor)): (active_session)  ? (timed_in) ? const SizedBox() : QRScanner(faculty: widget.faculty, report: report) 
            
            : Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                      TextSpan(text: "Class Sessions\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                      TextSpan(text: "Fill out session details and start class.\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
                    ])),
                  ),
                ),
              ),
               SizedBox(
                  width: double.infinity,
                  height: 20*scaleFactor,
                  child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 20*scaleFactor,
                ),
                Expanded(child: Padding(padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                                       Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(
                            height: 50,
                            width: 140.0*scaleFactor,
                            child: TextFormField(
                              style: TextStyle(fontSize: 18*scaleFactor),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            initialValue: "Laboratory",
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
                          initialSelection : lab,
                          hintText: "Select Laboratory",
                          enabled: (laboratories.isNotEmpty),
                            width: 200*scaleFactor,
                            textStyle: TextStyle(fontSize: 16*scaleFactor),
                            onSelected: (String? value)=>{
                              setState(()=>lab = value)
                            },
                            dropdownMenuEntries: laboratories.keys.toList().map<DropdownMenuEntry<String>>((String lab) {
                              return DropdownMenuEntry<String>(value: laboratories[lab]!, label: lab);
                            }).toList(),
                          )
                      ],),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(
                            height: 50,
                            width: 140.0*scaleFactor,
                            child: TextFormField(
                              style: TextStyle(fontSize: 18*scaleFactor),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            initialValue: "Course",
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
                          initialSelection: course,
                          enabled: (courses.isNotEmpty && lab != null),
                          hintText: "Choose Course",
                          textStyle: TextStyle(fontSize: 16*scaleFactor),
                            width: 200*scaleFactor,
                            onSelected: (String? value){
                              loadLevels(value!);
                              setState(()=> course = value);
                            },
                            dropdownMenuEntries: courses.map<DropdownMenuEntry<String>>((String course) {
                              return DropdownMenuEntry<String>(value: course, label: course);
                            }).toList(),
                          )
                      ],),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(
                            height: 50,
                            width: 140.0*scaleFactor,
                            child: TextFormField(
                              style: TextStyle(fontSize: 18*scaleFactor),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            initialValue: "Year Level",
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
                          initialSelection: level,
                        controller:levelController,
                        hintText: "Choose Year Level",
                         enabled: (levels.isNotEmpty),
                          textStyle: TextStyle(fontSize: 16*scaleFactor),
                            width: 200*scaleFactor,
                            onSelected: (String? value){
                              loadBlocks(value!);
                              setState(()=>level = value);
                            },
                            dropdownMenuEntries: levels.map<DropdownMenuEntry<String>>((String course) {
                              return DropdownMenuEntry<String>(value: course, label: course);
                            }).toList(),
                          )
                      ],),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        SizedBox(
                            height: 50,
                            width: 140.0*scaleFactor,
                            child: TextFormField(
                              style: TextStyle(fontSize: 18*scaleFactor),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            initialValue: "Block",
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
                          initialSelection: block,
                          controller:blockController,
                          hintText: "Choose Block",
                          enabled: (blocks.isNotEmpty),
                            width: 200*scaleFactor,
                            textStyle: TextStyle(fontSize: 16*scaleFactor),
                            onSelected: (String? value)=>{
                              setState(()=>block = value)
                            },
                            dropdownMenuEntries: blocks.keys.toList().map<DropdownMenuEntry<String>>((String course) {
                              return DropdownMenuEntry<String>(value: course, label: course);
                            }).toList(),
                          )
                      ],),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           SizedBox(
                            height: 50,
                            width: 240.0*scaleFactor,
                            child: TextFormField(
                              controller:dateController,
                              style: TextStyle(fontSize: 16*scaleFactor),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                  ),
                                ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                           SizedBox(
                            height: 50,
                            width: 120.0*scaleFactor,
                            child: TextFormField(
                              controller: timeController,
                              style: TextStyle(fontSize: 16*scaleFactor),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                  ),
                                ),
                            ),
                          ),
                         
                    
                      ],),
                    ),

                        Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: 250.0 *  scaleFactor,
                                height:50.0 * scaleFactor,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                    backgroundColor: 
                                      (block != null) ? Colors.blue : Colors.grey,
                                    ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.qr_code),
                                      Text("Regenerate QRs", style: TextStyle(fontSize:20 * scaleFactor, fontWeight: FontWeight.w600)),
                                    ],
                                  ), 
                                  onPressed: ()=>{
                                    if(block != null){
                                      generateQR()
                                    }
                                  },)),
                            ),
                          ),
                  ],)
                )),
            
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 400.0 *  scaleFactor,
                      height:50.0 * scaleFactor,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: 
                            (course != null && level != null && block != null && !startingClass) ? Colors.orange : Colors.grey,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                          ),
                        child: Text((startingClass) ? "STARTING" :"START CLASS", style: TextStyle(fontSize:20 * scaleFactor, fontWeight: FontWeight.w600)), 
                        onPressed: (){
                          if(course != null && level != null && block != null && !startingClass){
                            try{
                              startClass();
                            }catch(e) {
                              showError(context, "Problem connecting to server");
                            }
                          }
                        },)),
                  ),
                ),
               SizedBox(height: 90*scaleFactor,)
              ],
            ),
        ),
        // Create Bottom  Navigation Bar
          bottomNavigation(scaleFactor,context,widget.faculty, 4)
      ],),
    );
  }
}


class FacultyManageCourse extends StatefulWidget {
  final Faculty faculty;
  final Course? course;
  const FacultyManageCourse({super.key, required this.faculty, this.course});

  @override
  State<FacultyManageCourse> createState() => _FacultyManageCourseState();
}

class _FacultyManageCourseState extends State<FacultyManageCourse> {


  Map<String, String> selections = {};

  Map<String, String> addOptions = {};

  List<String> menuTitle = ["HANDLED COURSES", "HANDLED LEVELS", "HANDLED BLOCKS","HISTORY", "ENTRIES"];
  List<String> menuDescription = [
    "Remove added items using hold gesture",
    "Remove added items using hold gesture",
    "Remove added items using hold gesture",
    "Showing class sessions for the last 30 days.",
    "Showing entries inside class session."
  ];

  List<Course> assignedCourses = [];

  List<Course> availableCourses = [];
  
  List<String> takenBlocks = [];
  List<Report> facultyReports = [];
  List<Session> _sessions = [];

  bool hasLoaded = false;


  String? _selectedCourse;
  String? _selectedLevel;

  Map<String, String> _courses ={};
   Map<String, String> _levels = {};
   Map<String, String> _blocks = {};

  String? course;
  String? level;
  String? block;
TextEditingController courseController = TextEditingController();
    TextEditingController levelController = TextEditingController();
      TextEditingController blockController = TextEditingController();

  int currentTab = 0;

  Report? _activeReport;

  @override
  void initState() 
  {
    // TODO: implement initState
    super.initState();

    getAvailableCourses().then((value) => getCourses().then((value){
      loadCourses();
 
      if(mounted){
          if(widget.course != null){
            loadLevels(widget.course!.courseID!);
          }
         setState(() {
          if(widget.course != null){
                 course = widget.course!.courseID;
                _selectedCourse = widget.course!.courseID;
                  navigationHeader[1]= parseAcronym(widget.course!.course);
                currentTab = currentTab= 1;
          }
          hasLoaded = true;
        });
      }
      
    }));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    blockController.dispose();
    levelController.dispose();
    courseController.dispose();
    super.dispose();
  }

  Future getAvailableCourses() async {
    var url = Uri.parse("${Connection.host}flutter_php/availablecourses.php");
    var response = await server.post(url, body: {
    });
    var data = json.decode(response.body);
    if(data["success"]){
        List<Course> courses = [];
        data['rows'].forEach((row){
            courses.add(
              Course(id: row['ID'],courseID: row['courseID'], levelID: row['levelID'] ,  course: row['course'], year: row['level'], block: row['block'])
            );
    });
     if(mounted){
       setState(() {
          availableCourses = courses;
        });
     }
    }
  }


 Future endClass() async {
    var url = Uri.parse("${Connection.host}flutter_php/faculty_endclass.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });

    var data = json.decode(response.body);
    if(!data["success"]){
      print("error");
    }
  }
  
  Future getCourses() async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_loadcourses.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });
    var data = json.decode(response.body);
    if(data["success"]){
      List<Course> courses = [];
      List<String> takenBlocks = [];
      data['rows'].forEach((row){
          courses.add(
            Course(id: row['ID'],courseID: row['courseID'], levelID: row['levelID'] ,  course: row['course'], year: row['level'], block: row['block'])
          );
          takenBlocks.add(row['ID']);
      });

      if(mounted){
        setState(() {
          assignedCourses = courses;
          this.takenBlocks = takenBlocks;
        });
      }
    }
  }

  Future loadReports(String blockID) async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_getclasssessions.php");
    var response = await server.post(url, body: {
      'id' : widget.faculty.id,
      'blockID': blockID,
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
          facultyReports = reports;
        });
      }
    }
  }
  Future loadSessions(Report report) async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_getsessions.php");
    var response = await server.post(url, body: {
      'classID': report.id,
    });
    var data= json.decode(response.body);
    if(!data['success']){
      print(data['message']);
    }else{
      var rows = data['rows'];
      List<Session> sessions = [];
      rows.forEach((dynamic row)=>{
        sessions.add(decodeSession(row))
      });
      if(mounted){
        setState(() {
          _sessions = sessions;
        });
      }
    }
  }

  void loadCourses(){
    Map<String,String> courses = {};
    for (var _course in assignedCourses) {
      courses[_course.course] = _course.courseID!;
    }

   if(mounted){
     setState(() {
      selections = courses;
    });
   }
  }


 void loadLevels(String courseID) async {
    Map<String,String> courses = {};
    for (var _course in assignedCourses) {
      if(_course.courseID == courseID || _selectedCourse == _course.courseID) {
        courses[_course.year] = _course.levelID!;
      }
    }

   if(mounted){
     setState(() {
      selections = courses;
      _selectedCourse = courseID;
    });
   }
  }

  void loadBlocks(String levelID){
    Map<String,String> courses = {};
    for (var _course in assignedCourses) {
      if(_course.levelID == levelID || _selectedLevel == _course.levelID){
        courses[_course.block] = _course.id;
      }
    }

    if(mounted){
      setState(() {
      selections = courses;
      _selectedLevel = levelID;
    });
    }
  }


  Future loadOptions() async{
   Map<String, String> courses ={};
   Map<String, String> levels = {};
   Map<String, String> blocks = {};
   for (var _course in availableCourses) {
    if(!courses.containsKey(_course.course)){
        courses[_course.course] = _course.courseID!;
    }

    if(!levels.containsKey(_course.year) && _course.courseID == course){ 
        levels[_course.year] = _course.levelID!;
    }

    if(!blocks.containsKey(_course.block) && !takenBlocks.contains(_course.id) && _course.levelID == level ){
        blocks[_course.block] = _course.id;
    }
   }

    if(mounted){
       setState(() {
        _courses = courses;
        _levels = levels;
        _blocks = blocks;
      });
    }
  } 

  bool  addingClass = false;
  Future addClass() async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_addcourse.php");
    var response = await server.post(url, body: {
      'id': widget.faculty.id,
      'course_id' : block
    });

    var data = json.decode(response.body);

    if(!data['success']){
      print("error");
    }
  }

  

  Future removeClass(String id) async{
    var ids =[];
    assignedCourses.forEach((assignment)=>{
      if(currentTab == 0){
        if(id == assignment.courseID){
          ids.add(assignment.id)
        }
      }
      else if(currentTab == 1){
        if(id == assignment.levelID){
          ids.add(assignment.id)
        }
      }else{
        if(currentTab == 2){
          if(id == assignment.id){
            ids.add(assignment.id)
          }
        }
      }
    });
    var url = Uri.parse("${Connection.host}flutter_php/faculty_removecourse.php");
    var response = await server.post(url, body: {
      "id" : widget.faculty.id,
      "ids": json.encode(ids),
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print('error');
    }
  }
  
  List<String> navigationHeader = ["", "","","",""];


  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return  WillPopScope(
      onWillPop: ()async{
      if(currentTab >0 && hasLoaded){
                  if(currentTab == 2){
                    loadLevels(_selectedCourse!);
                  }
                  if(currentTab == 1){
                    loadCourses();
                  }
                  setState(()=>currentTab-=1);
                }
        return false;
      },
      child: Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: appBar(scaleFactor , "MY COURSES",  context, currentTab, (){
            if(currentTab >0 && hasLoaded){
                  if(currentTab == 2){
                    setState((){
                      level = null;
                      block = null;
                    });
                      loadLevels(_selectedCourse!);
                  }
                  if(currentTab == 1){
                    
                    setState((){
                      course = null;
                      level = null;
                      block = null;
                    });
                    loadCourses();
                  }
                  setState(()=>currentTab-=1);
                }
          }, widget.faculty),
            body: (!hasLoaded) ? Center(child:loader(scaleFactor),) :Column(
              mainAxisAlignment: MainAxisAlignment.end,
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
                      TextSpan(text: "${menuTitle[currentTab]}${(currentTab==0)? "":" ( ${navigationHeader[currentTab]} )"}\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                      TextSpan(text: "${menuDescription[currentTab]}.\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
                    ])),
                  ),
                ),
              ),
               SizedBox(
                  width: double.infinity,
                  height: 20*scaleFactor,
                  child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                ),
                Expanded(child: Padding(padding: const EdgeInsets.all(20.0),
                  child: (currentTab == 3)? 
                  (facultyReports.isEmpty) ? const Center(child:Text("Nothing Yet.")) :
                  ListView.builder(
                    itemCount:facultyReports.length,
                    itemBuilder: (context, int index){
                      return FacultyHistoryButton(report: facultyReports[index],  onSubmit:(){
                          showDialog(context: context, builder: (context) => AlertDialog( 
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                              title: const Text("Are you sure you want to end class and submit forms to the admin?"),
                              actions: [
                               TextButton(child: const Text("Yes"),
                                  onPressed: (){
                                  popUpMessage(context, "Please Wait");
                                    endClass().then((value)
                                                    {     
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                      Navigator.pushReplacement(
                                                          context,
                                                        PageRouteBuilder(
                                                            pageBuilder: (context , anim1, anim2) =>
                                                                FacultyHome(faculty: widget.faculty,)));
                                                    });
                                  }
                                ),
                                TextButton(child: const Text("No"),
                                    onPressed: ()=>{
                                          Navigator.of(context).pop()
                                    }
                                  ),
                                
                              ],
                            ));
                      }, onView:(){
                        navigationHeader[4] =  "${parseDate(facultyReports[index].timeIn)} ${parseTime(facultyReports[index].timeIn)}";
                        setState(() {
                          _activeReport = facultyReports[index];
                        });
                        setState((){
                            currentTab += 1;
                            hasLoaded = false;
                          });
                        loadSessions(facultyReports[index]).then((x)=> setState(() {hasLoaded = true;}));
                      });
                    }
                  )
                  :(currentTab ==4) ?  (_sessions.isEmpty) ? const Center(child:Text("No Entries")) :
                   ListView.builder(
                    itemCount:_sessions.length,
                    itemBuilder: (context, int index){
                      return SessionHistoryButton(
                        session: _sessions[index],
                        report: _activeReport!,  onEdit:(){
                         popUpMessage(context, "Please Wait");
                          getStudent(_sessions[index].studentQR!).then((student)=>{
                            getDevice(_sessions[index].deviceQR!).then((device){
                  Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                        context,
                                      PageRouteBuilder(
                                          pageBuilder: (context , anim1, anim2) =>
                                              Evaluation(faculty: widget.faculty,
                                                student: student,
                                                device: device, screen:"Manage Course",
                                                session: _sessions[index],
                                              )));
                            })
                          });
                        }, isEditable: true);
                    }
                  )
                  : ListView.builder(
                    itemCount: selections.length+1,
                    itemBuilder: (context, int index){
                      if(index != selections.length){
                        return FacultySelectButton(
                          icon: (currentTab == 2)? const Icon(Icons.history) : const Icon(Icons.arrow_right),
                          label: selections.keys.toList()[index],
                     onPress: (){
                          if(currentTab == 0){
                            setState((){
                              navigationHeader[1]= parseAcronym(selections.keys.toList()[index]);
                              course = selections[selections.keys.toList()[index]]!;
                               _selectedCourse = selections[selections.keys.toList()[index]]!;
                            }
                            );
                            loadLevels(selections[selections.keys.toList()[index]]!);
                            setState(() {
                              currentTab+=1;
                            });
                          }else if(currentTab == 1){
                            switch(selections.keys.toList()[index]){
                              case "First Year":
                                navigationHeader[2]  = "${parseAcronym(navigationHeader[1])} - 1ST YEAR";
                                break;
                              case "Second Year":
                                navigationHeader[2] = "${parseAcronym(navigationHeader[1])} - 2ND YEAR";
                                break;
                              case "Third Year":
                                navigationHeader[2] = "${parseAcronym(navigationHeader[1])} - 3RD YEAR";
                                break;
                              case "Fourth Year":
                                navigationHeader[2] = "${parseAcronym(navigationHeader[1])} - 4TH YEAR";
                                break;
                              case "Fifth Year":
                                navigationHeader[2] = "${parseAcronym(navigationHeader[1])} - 5TH YEAR";
                                break;
                            }
                            setState(() {
                                 level = selections[selections.keys.toList()[index]]!;
                                  _selectedLevel = selections[selections.keys.toList()[index]]!;
                            });
                            loadBlocks(selections[selections.keys.toList()[index]]!);
                            setState(() {
                              currentTab+=1;
                            });
                          }else{
                            navigationHeader[3]="${navigationHeader[2]} : ${selections.keys.toList()[index].toUpperCase()}";
                             setState(() {
                                hasLoaded = false;
                              });
                            loadReports(selections[selections.keys.toList()[index]]!).then((x){
                               setState(() {
                                hasLoaded = true;
                                currentTab+=1;
                              });
                            });
                          }
                        },
                        onLongPress: (){
                          // delete all
                           showDialog(context: context, builder: (context) => AlertDialog(
                            title: const Text("Are you sure you want to delete item and its contents?"),
                            actions: [
                              TextButton(child: const Text("Yes"),onPressed: (){
                                setState((){
                                  hasLoaded = false;
                                });
                                  removeClass(selections[selections.keys.toList()[index]]!).then((a){
                                    getCourses().then((value) {
                                      if(currentTab == 0){
                                        loadCourses();
                                      }else if(currentTab == 1){
                                        loadLevels(_selectedCourse!);
                                      }else{
                                        loadBlocks(_selectedLevel!);
                                      }
                                      setState((){
                                        hasLoaded = true;
                                      });
                                    });
                                  
                                  });
                                 Navigator.of(context).pop();
                              }),
                              TextButton(child: const Text("No"),onPressed: ()=>{
                                 Navigator.of(context).pop()
                              })
                            ],
                            ));
                        },
                        );
                      }else{
                        return Padding(padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 45.0,
                              child:ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
                                ),
                                child: const Center(child: 
                                  Icon(Icons.add)
                                ,),
                              onPressed: (){
                                if(currentTab == 0){
                                  courseController.text = "";
                                   levelController.text = "";
                                    blockController.text = "";
                                  setState(() {
                                    course = null;
                                    level = null;
                                     block = null;
                                     _levels = {};
                                     _blocks = {};
                                  });
                                 loadOptions();
                                }
                                if(currentTab == 1){
                                levelController.text = "";
                                  blockController.text = "";
                                   setState(() {
                                    level = null;
                                    block = null;
                                    _blocks = {};
                                  });
                                  loadOptions();
                                }
                                if(currentTab == 2){
                                  blockController.text = "";
                                  setState(() {
                                    block = null;
                                  });
                                  loadOptions();
                                }
                                showDialog(context: context, builder: (context) => StatefulBuilder(
                                  builder: (context,setState) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      clipBehavior: Clip.antiAlias,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                      content: SizedBox(
                                        width: 500*scaleFactor,
                                        height: 460*scaleFactor,
                                        child: Column(
                                                children: [
                                                  const SizedBox(width: double.infinity,
                                                    height: 60.0,
                                                    child: DecoratedBox(decoration: BoxDecoration(color: Colors.blue),
                                                      child: Align(
                                                        alignment:Alignment.center,
                                                        child: Text("Add a course",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Column(children: [
                                                        Padding(
                            padding: const EdgeInsets.all(5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                      DropdownMenu(
                                                        enabled: (_courses.isNotEmpty && currentTab <= 0),
                                                        initialSelection: (course != null) ? course: null,
                                                        hintText: "Choose Course",
                                                        textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                          width: 250*scaleFactor,
                                                          onSelected: (String? value){

                                                            levelController.text = "";
                                                             blockController.text = "";
                                                            setState((){
                                                              course = value;
                                                              level = null;
                                                              block = null;
                                                              _levels = {};
                                                              _blocks = {};
                                                            });
                                                          loadOptions();
                                                          },
                                                          dropdownMenuEntries: _courses.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                            return DropdownMenuEntry<String>(value: _courses[item]!, label: item);
                                                          }).toList(),
                                                        )
                                                    ],),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                    
                                                      DropdownMenu(
                                                      initialSelection: (level != null) ? level: null,
                                                      controller:levelController,
                                                      hintText: "Choose Year Level",
                                                      enabled: (_levels.isNotEmpty  && currentTab <= 1),
                                                        textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                          width: 250*scaleFactor,
                                                          onSelected: (String? value){
                                                            blockController.text = "";
                                                            setState((){
                                                              level = value;
                                                              block = null;
                                                              _blocks = {};
                                                            });
                                                          loadOptions();
                                                          },
                                                          dropdownMenuEntries: _levels.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                            return DropdownMenuEntry<String>(value: _levels[item]!, label: item);
                                                          }).toList(),
                                                        )
                                                    ],),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                     
                                                      DropdownMenu(
                                                        controller:blockController,
                                                        hintText: "Choose Block",
                                                        enabled: (_blocks.isNotEmpty),
                                                          width: 250*scaleFactor,
                                                          textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                          onSelected: (String? value)=>{
                                                            setState(()=>block = value)
                                                          },
                                                          dropdownMenuEntries: _blocks.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                            return DropdownMenuEntry<String>(value: _blocks[item]!, label: item);
                                                          }).toList(),
                                                        )
                                                    ],),
                                                  ),
                                                ],)
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
                                                Expanded(child: TextButton(child: Text((addingClass)? "ADDING" : "ADD", style: TextStyle(color: (block == null || addingClass) ? Colors.grey:Colors.white, fontWeight: FontWeight.bold)),
                                                onPressed: (){
                                                  if(block!=null && !addingClass){
                                                    setState((){addingClass=true;});
                                                    addClass().then((message)=>{
                                                      getCourses().then((message){
                                                        if(currentTab == 0){
                                                          loadCourses();
                                                        }
                                                        if(currentTab == 1){
                                                          loadLevels(_selectedCourse!);
                                                        }
                                                        if(currentTab == 2){
                                                          loadBlocks(_selectedLevel!);
                                                        }
                                                            setState((){addingClass=false;});
                                                        Navigator.of(context).pop();
                                                      })
                                                    });
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
                                
                              },
                              ) 
                              
                              ),
                          );
                      }
                    } ,
                  ) ,
                )),
                SizedBox(height: 90*scaleFactor,)
              ],
            ),
        ),
        // Create Bottom  Navigation Bar
         bottomNavigation(scaleFactor, context, widget.faculty,3)
      ],),
    );
  }
}


class FacultyScheduling extends StatefulWidget {
  final Faculty faculty;
  const FacultyScheduling({super.key, required this.faculty});

  @override
  State<FacultyScheduling> createState() => _FacultySchedulingState();
}


class _FacultySchedulingState extends State<FacultyScheduling> {

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
        getCourses().then((x){  
          if(mounted){
          setState((){
            _hasLoaded = true;  
          });
        }
        })
        
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
      var url = Uri.parse("${Connection.host}flutter_php/faculty_getschedules.php");
      var response = await server.post(url, body: {
        'id': widget.faculty.id,
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
                  scheduleAlarm(schedule);
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
      var url = Uri.parse("${Connection.host}flutter_php/faculty_addschedule.php");
      var response = await server.post(url, body: {
        'id': widget.faculty.id,
        'labID': _optionLabID!,
        'blockID' : block,
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

  String? _selectedCourse;
  String? _selectedLevel;
  List<String> weekdays = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY","FRIDAY", "SATURDAY"];
  String? selectedDay;

  TimeOfDay? startTime;
    TimeOfDay? endTime;

  Map<String, String> _courses ={};
   Map<String, String> _levels = {};
   Map<String, String> _blocks = {};

  String? course;
  String? level;
  String? block;

    TextEditingController levelController = TextEditingController();
      TextEditingController blockController = TextEditingController();

        Map<String, String> selections = {};

  Map<String, String> addOptions = {};

Future getCourses() async{
    var url = Uri.parse("${Connection.host}flutter_php/faculty_loadcourses.php");
    var response = await server.post(url, body: {
      "id": widget.faculty.id,
    });
    var data = json.decode(response.body);
    if(data["success"]){
      List<Course> courses = [];
      List<String> takenBlocks = [];
      data['rows'].forEach((row){
          courses.add(
            Course(id: row['ID'],courseID: row['courseID'], levelID: row['levelID'] ,  course: row['course'], year: row['level'], block: row['block'])
          );
          takenBlocks.add(row['ID']);
      });

      if(mounted){
        setState(() {
          assignedCourses = courses;
          takenBlocks = takenBlocks;
        });
      }
    }
  }

  

  Future loadOptions() async{
   Map<String, String> courses ={};
   Map<String, String> levels = {};
   Map<String, String> blocks = {};
   for (var _course in assignedCourses) {
    if(!courses.containsKey(_course.course)){
        courses[_course.course] = _course.courseID!;
    }

    if(!levels.containsKey(_course.year) && _course.courseID == course){ 
        levels[_course.year] = _course.levelID!;
    }

    if(!blocks.containsKey(_course.block) &&  _course.levelID == level){
        blocks[_course.block] = _course.id;
    }
   }

    if(mounted){
       setState(() {
        _courses = courses;
        _levels = levels;
        _blocks = blocks;
      });
    }
  } 

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
                  child: Text("${schedule.course} $level-${schedule.block.replaceAll("Block ", "")}",
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
      "from" : "schedules"
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
    return WillPopScope(child: Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,

          appBar:appBar(scaleFactor, "MY SCHEDULES", context, _currentTab, null, widget.faculty),
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
                                              onPressed:()  async {
                                              setState(() {
                                                startTime = null;
                                                endTime = null;
                                                course = null;
                                                block = null;
                                                level = null;
                                                selectedDay = null;
                                              });
                                              await showDialog(context:context, builder:(context)=>
                                                          SimpleDialog( 
                                                            alignment: Alignment.center,
                                                            backgroundColor: Colors.transparent,
                                                            children:
                                                                weeklyButtons()
                                                          )
                                                        );
                                        if(selectedDay == null) return;
                                        loadOptions().then((x){
                                                    showDialog(context: context, builder: (context) => StatefulBuilder(
                                        builder: (context,setState) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.zero,
                                            clipBehavior: Clip.antiAlias,
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                            content: SizedBox(
                                              width: 500*scaleFactor,
                                              height: 650*scaleFactor,
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
                                                               loadOptions();
                                                            },
                                                            dropdownMenuEntries: _laboratories.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                              return DropdownMenuEntry<String>(value: _laboratories[item]!.id, label: item);
                                                            }).toList(),
                                                          )
                                                      ],),
                                                                                                      ),
                                                                                                  Padding(
                                                                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                        DropdownMenu(
                                                          enabled: (_courses.isNotEmpty && _optionLabID != null),
                                                          initialSelection: (course != null) ? course: null,
                                                          hintText: "Choose Course",
                                                          textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                            width: 320*scaleFactor,
                                                            onSelected: (String? value){
                                                             levelController.text = "";
                                                              blockController.text = "";
                                                              setState((){
                                                                course = value;
                                                                level = null;
                                                                block = null;
                                                                _blocks = {};
                                                              });
                                                               loadOptions();
                                                            },
                                                            dropdownMenuEntries: _courses.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                              return DropdownMenuEntry<String>(value: _courses[item]!, label: item);
                                                            }).toList(),
                                                          )
                                                      ],),
                                                                                                      ),
                                                                                                      Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                      
                                                        Flexible(
                                                          child: DropdownMenu(
                                                          initialSelection: (level != null) ? level: null,
                                                          controller:levelController,
                                                          hintText: "Choose Year Level",
                                                          enabled: (_levels.isNotEmpty),
                                                            textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                              width: 160*scaleFactor,
                                                              onSelected: (String? value){
                                                                blockController.text = "";
                                                                setState((){
                                                                  level = value;
                                                                  block = null;
                                                                });
                                                                  loadOptions();
                                                              },
                                                              dropdownMenuEntries: _levels.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                                return DropdownMenuEntry<String>(value: _levels[item]!, label: item);
                                                              }).toList(),
                                                            ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Flexible(child:  DropdownMenu(
                                                          controller:blockController,
                                                          hintText: "Choose Block",
                                                          enabled: (_blocks.isNotEmpty),
                                                            width: 160*scaleFactor,
                                                            textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                            onSelected: (String? value)=>{
                                                              setState(()=>block = value)
                                                            },
                                                            dropdownMenuEntries: _blocks.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                              return DropdownMenuEntry<String>(value: _blocks[item]!, label: item);
                                                            }).toList(),
                                                          ),)
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
                                                Expanded(child: TextButton(child: Text((_hasLoaded) ? "ADD" : "ADDING", style: TextStyle(color: (block == null || !isValidTime(startTime, endTime) || !_hasLoaded) ? Colors.grey:Colors.white, fontWeight: FontWeight.bold)),
                                                onPressed: (){
                                                  if(block!=null && isValidTime(startTime, endTime) && _hasLoaded ){
                                                    setState((){
                                                      _hasLoaded = false;
                                                        if(collapsed.contains( weekdays.indexOf(selectedDay!.toUpperCase()))){
                                                          collapsed.remove( weekdays.indexOf(selectedDay!.toUpperCase()));
                                                        }
                                                      
                                                    });
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
                                  height: 100*scaleFactor,
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
        bottomNavigation(scaleFactor, context, widget.faculty,2),
      ],
    ), onWillPop: ()async{
      return false;
    });
  }
}