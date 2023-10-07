import 'dart:async';
import 'dart:convert';

import 'package:bupolangui/components/custombuttons.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/models/session.dart';
import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:bupolangui/pages/viewprofile.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as server;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';



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
    // _timer = Timer.periodic(Duration(seconds: 1), (timer) { 
    //   refresh();
    // });

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
                                child: const Text("PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:(){
                                   Navigator.push(
                                      context,
                                    PageRouteBuilder(
                                        pageBuilder: (context , anim1, anim2) =>
                                            ViewProfile(account: widget.student)));
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
                  size: 400.0 * scaleFactor,
                  ),
              ),
               SizedBox(height: 40*scaleFactor,),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 45*scaleFactor,
                    width: 240.0*scaleFactor,
                    child:DecoratedBox(
                        decoration: BoxDecoration(color: (refreshing)? Colors.grey :  Colors.blue,
                          borderRadius: const BorderRadius.all(Radius.circular(10.0))
                        ),
                        child: TextButton(child: Center(child: Text((refreshing)? "REFRESHING" : "REFRESH", style: const TextStyle(color: Colors.white,letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 20),)),
                          onPressed: (){
                            refresh();
                          
                          },
                        ),
                      ),),
                ),
              ],
            ),
              SizedBox(height: 20*scaleFactor,),
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 45*scaleFactor,
                  width: 180.0*scaleFactor,
                  child:DecoratedBox(
                      decoration: BoxDecoration(color: (loadingHistory)? Colors.grey: Colors.orange,
                        borderRadius: const BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: TextButton(child: Center(child: Text((loadingHistory)? "Loading" : "HISTORY", style: const TextStyle(color: Colors.white,letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 20),)),
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
                    ),),
              ],
            ),
          ],
        )
      ),
    );
  }

}