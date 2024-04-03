import 'dart:convert';

import 'package:bupolangui/components/preloader.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/pages/admin_dashboard.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/pages/login.dart';
import 'package:bupolangui/pages/signup.dart';
import 'package:bupolangui/pages/studentview.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as server;
import 'package:flutter/foundation.dart';
import  './stud/dart-js.dart' if(dart.library.js) 'dart:js'  as js;


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  bool hasLoaded = false;
  
  void getLastLogin() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final loginID = prefs.getString("ID");
  final loginType = prefs.getString("Type");
  if(mounted){
    if(loginID != null){
      
        var url = Uri.parse("${Connection.host}flutter_php/getaccount.php");
          var response = await server.post(url, body: {
            'id': loginID,
            'type' : loginType
          });

          var data= json.decode(response.body);

          if(!data['success']){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                duration: Duration(milliseconds:1500),
                content: Text('Unable to login, account has been logged out.')),
            );
            await prefs.remove('ID');
            await prefs.remove('Type');
          }else{
            switch(loginType){
                // ignore: use_build_context_synchronously
                case 'faculty': Navigator.push(
                  context,
                MaterialPageRoute(
                    builder: (context) =>
                        FacultyHome(faculty: decodeFaculty(data['row']),)));
                break;
                // ignore: use_build_context_synchronously
                case 'admin': Navigator.push(
                  context,
                MaterialPageRoute(
                    builder: (context) =>
                        Dashboard(admin: decodeAdmin(data['row']))));
                break;
                // ignore: use_build_context_synchronously
                case 'student': Navigator.push(
                  context,
                MaterialPageRoute(
                    builder: (context) =>
                        StudentView(title: 'Student Portal', student: decodeStudent(data['row']) )));
            }

          }
    }
      setState(() {
        hasLoaded = true;
      });
    }
  }

  @override
  void initState(){
    super.initState();
    getLastLogin();
  }
  
  @override
  Widget build(BuildContext context) {
    double scaleFactor = (MediaQuery.of(context).size.height/1000);
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      body: (!hasLoaded) ?  Center(child: loader(scaleFactor)): Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover
          ),
        ),
        child: (kIsWeb && defaultTargetPlatform==TargetPlatform.android) ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           Center(
             child: SizedBox(
                width: 320.0 * scaleFactor,
                height: 320.0 * scaleFactor,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:  BorderRadius.all(Radius.circular(250.0)),
                    image:  DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/Logo.png" )
                  ) ,)
                )
              ),
           ),
           SizedBox(height: 35*scaleFactor,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
            ),
            onPressed: () async{
              // http://<address>:<port>/flutter_php/<app-name>.apk
              js.context.callMethod("open",["https://drive.google.com/uc?export=download&id=1iZQKn82-nWMpDreT1fBEBfcj2-L_ZI3d"]);
            }, child: const Padding(
              padding:  EdgeInsets.all(10.0),
              child:  Text("Download the app here!", style:  TextStyle(fontSize: 16.0),),
            ))
        ],
      ) : Column(
          children:[
              SizedBox(height: 80.0 * scaleFactor),
              Center(
                child: SizedBox(
                    width: 150.0 * scaleFactor,
                    height: 150.0 * scaleFactor,
                    child: Image.asset('assets/images/bupolanguiseal.png',
                      isAntiAlias: true,
                    )
                  ),
              ),
              SizedBox(
                    height: 10.0  * scaleFactor,
                  ),
              Text(
                    'Bicol University Polangui',
                    style: TextStyle(
                      fontSize: 20  * scaleFactor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2 ,
                      color: Colors.white,
                      shadows: const <Shadow>[
                        Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),]
                    ),
                  ),
              SizedBox(
                    height: 60.0  * scaleFactor,
                  ),
              Expanded(
                child: Column(
                      children: [
                        SizedBox(
                          height: 90.0  * scaleFactor,
                        ),
                        Center(
                          child: SizedBox(
                              width: 280.0 * scaleFactor,
                              height: 280.0 * scaleFactor,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius:  BorderRadius.all(Radius.circular(250.0)),
                                  image:  DecorationImage(
                                    fit: BoxFit.fill,
                                    image: AssetImage("assets/images/Logo.png" )
                                ) ,)
                              )
                            ),
                        ),
                        SizedBox(
                          height: 40.0  * scaleFactor,
                        ),
                      ],
                    ),
              ),
              SizedBox(
                    height: 90.0  * scaleFactor,
                    width: double.infinity,
                    child: Row(children: [
                      Expanded(
                        child: SizedBox(
                          height: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const ContinuousRectangleBorder(),
                              backgroundColor: const Color.fromARGB(255, 235, 111, 10),
                            ),
                            onPressed: () async{
                                  //action code when clicked
                                    var result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Signup(title: '',)));
                                  if(result!=null){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          duration: Duration(milliseconds:3500),
                                          content: Text(result, style: const TextStyle(fontSize: 16.0),)),
                                      );
                                  }
                                },
                            child: 
                              Text('SIGN UP',
                              style : TextStyle(
                                    fontSize: 20  * scaleFactor,
                                    letterSpacing: 5.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                ), 
                              ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const ContinuousRectangleBorder(),
                              backgroundColor: const Color.fromARGB(255, 235, 111, 10),
                            ),
                            onPressed: (){
                                    //action code when clicked
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Login(title: '',)));
                                },
                            child: 
                              Text('LOG IN',
                              style : TextStyle(
                                    fontSize: 20  * scaleFactor,
                                    letterSpacing: 5.0,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                ),
                              ),
                          ),
                        ),
                      ),
                    ],
                    )
                  )
          ] ,
        ),
      ),
    );
  }
}