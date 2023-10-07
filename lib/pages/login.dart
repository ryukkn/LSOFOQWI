import 'dart:convert';

import 'package:bupolangui/pages/admin_dashboard.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/pages/studentview.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as server;
import 'package:bupolangui/functions/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  String? _errorMessage;
  bool _logingIn = false;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    if((kIsWeb)){
      setAccountType(2);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }


  void setAccountType(int index) {
    setState(() {
      _active = index;
    });
  }

  // // Google Log in
  // final GoogleSignIn googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     'https://www.googleapis.com/auth/contacts.readonly',
  //   ],
  // );


  // Future<void> googleLogin() async {
  //   try {
  //     GoogleSignInAccount? userAccount = await googleSignIn.signIn();
  //     print(userAccount!.displayName);
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(
  //         context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               const QRScanner(title: '')));

  //   } catch (error) {
  //     print(error);
  //   }
  // }

  void googleLogin() {
    setState(() {
       _errorMessage = "This feature is not yet supported";
    });
  }


  // Server Login
  Future login(int priviledge) async{
    var url = Uri.parse("${Connection.host}flutter_php/login.php");
    try{
      setState(() {
        _logingIn = true;
      });
        var response = await server.post(url, body: {
        "email": email.text,
        "password": password.text,
        "priviledge": priviledge.toString()
      });

      var data = json.decode(response.body);

      if(data['success']){
        SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("ID", data['row']['ID']);
        setState(() {
          _logingIn = false;
        });
        switch(priviledge){
          case 1: 
          await prefs.setString("Type", "faculty");
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
          MaterialPageRoute(
              builder: (context) =>
                  FacultyHome(faculty: decodeFaculty(data['row']),)));
          break;
          case 2: 
           await prefs.setString("Type", "admin");
            // ignore: use_build_context_synchronously
            Navigator.push(
            context,
          MaterialPageRoute(
              builder: (context) =>
                  const Dashboard()));
          break;
       
          case 3: 
          await prefs.setString("Type", "student");
             // ignore: use_build_context_synchronously
          Navigator.push(
            context,
          MaterialPageRoute(
              builder: (context) =>
                  StudentView(title: 'Student Portal', student: decodeStudent(data['row']) )));
        }
      }else{
        setState(() {
          _errorMessage = data['message'];
          _logingIn = false;
        });
      }
    }catch(e){
      setState(() {
        _logingIn = false;
        _errorMessage = "Unable to connect to the server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   double scaleFactor = (MediaQuery.of(context).size.height/1000);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:  (kIsWeb
          &&  MediaQuery.of(context).size.width /  MediaQuery.of(context).size.height < 1.77
      ) ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Browser login is not supported on this resolution."),
          TextButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("return"))
        ],
      ),) : Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover
          ),
        ),
        child: Column(
          children:[
              SizedBox(
              height: 60.0 * scaleFactor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150.0 * scaleFactor,
                    height: 150.0 * scaleFactor,
                    child: Image.asset('assets/images/bupolanguiseal.png',
                      isAntiAlias: true,
                    )
                  ),
                ],
              ),
              SizedBox(
                    height: 30.0  * scaleFactor,
                  ),
              Container(
                width: (MediaQuery.of(context).size.width < 600.0) ? MediaQuery.of(context).size.width * 0.85 : 500.0,
                height: MediaQuery.of(context).size.height * 0.7,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(228, 255, 255, 255),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              child: Column(
                children: [
                  SizedBox(height: 20.0 * scaleFactor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      SizedBox(width: 40.0 * scaleFactor, height: 40.0 * scaleFactor,
                        child: Center(child: TextButton(onPressed: () => {Navigator.pop(context)}, 
                        child: Icon(Icons.arrow_back, color: Colors.black,
                          size: 24.0 * scaleFactor,                        
                        ),)),
                      ),
                      Center(
                        child: Text(
                        'Log in as',
                          style: TextStyle(
                            fontSize: 22  * scaleFactor,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2 ,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: 40.0 * scaleFactor, height: 40.0 * scaleFactor,),
                    ],),
                  ),
                  SizedBox(height: 10.0  * scaleFactor),
                  Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0  * scaleFactor),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               (!kIsWeb) ? TextButton(
                                onPressed: () => {
                                  setAccountType(1)
                                },
                                style: TextButton.styleFrom(backgroundColor: (_active == 1) ? Colors.orange  : Colors.transparent),
                                child: Text(
                                'FACULTY',
                                  style: TextStyle(
                                    fontSize: 20  * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2  * scaleFactor,
                                    color: (_active == 1) ? Colors.white :Colors.blue,
                                    ),
                                ),
                              ) : const SizedBox(),
                              (kIsWeb) ? TextButton(
                                onPressed: () => {
                                  setAccountType(2)
                                },
                                style: TextButton.styleFrom(backgroundColor: (_active == 2) ? Colors.orange : Colors.transparent),
                                child: Text(
                                'ADMINISTRATOR',
                                  style: TextStyle(
                                    fontSize: 20  * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2  * scaleFactor,
                                    color: (_active == 2) ? Colors.white :Colors.black,
                                    ),
                                ),
                              ): const SizedBox(),
                              (!kIsWeb) ? TextButton(
                                onPressed: () => {
                                  setAccountType(3)
                                },
                                style: TextButton.styleFrom(backgroundColor: (_active == 3) ? Colors.orange : Colors.transparent),
                                child: Text(
                                'STUDENT',
                                  style: TextStyle(
                                    fontSize: 20  * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2  * scaleFactor,
                                    color: (_active == 3) ? Colors.white :Colors.orange,
                                    ),
                                ),
                              ) : const SizedBox(),
                            ],
                          ),
                        ),
                      )
                    ),
                  SizedBox( height: 30.0  * scaleFactor ),
                  SizedBox(
                    height: 60.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding:EdgeInsets.symmetric(horizontal: 30.0 *scaleFactor),
                      child: TextFormField(
                        controller: email,
                        validator: (String? value){
                          if(value!.trim().isEmpty){
                            return "Field is Required";
                          }
                          return null;
                        },
                        style: TextStyle(
                                fontSize: 18  * scaleFactor,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0  * scaleFactor),
                  SizedBox(
                    height: 70.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: TextFormField(
                        obscureText: true,
                        controller: password,
                        validator: (String? value){
                          if(value!.trim().isEmpty){
                            return "Field is Required";
                          }
                          return null;
                        },
                        style: TextStyle(
                                fontSize: 18  * scaleFactor,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        SizedBox(
                          height: double.infinity,
                          width: (MediaQuery.of(context).size.width < 500)?MediaQuery.of(context).size.width * 0.4 : 200.0,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text((_errorMessage != null) ? _errorMessage! : '',
                                style: TextStyle(
                                    fontSize: 16 * scaleFactor,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.red,
                                  ),  
                              ),
                          ) ,
                        ),
                        TextButton(
                            onPressed: ()=>{},
                            child: Text('Forgot Password?',
                              style: TextStyle(fontSize: 14*scaleFactor),
                            ))
                      ],)
                    ),
                  ),
                  SizedBox(height: 20.0 * scaleFactor),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0 * scaleFactor),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(children: [
                            SizedBox(
                              height: 15.0 * scaleFactor,
                              width:  2.0 * scaleFactor ,
                              child: const DecoratedBox(decoration: BoxDecoration(
                                color: Colors.blue
                              )),
                            ),
                            SizedBox(
                              height: 2.0 * scaleFactor,
                              width: (MediaQuery.of(context).size.width < 600) ? MediaQuery.of(context).size.width * 0.25 : 180.0,
                              child: const DecoratedBox(decoration: BoxDecoration(
                                color: Colors.blue
                              )),
                            ),
                          ]),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Text('OR',
                              style: TextStyle(
                                  fontSize: 16 * scaleFactor,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.2,
                                  color: Colors.black,
                                ),  
                            ) ,
                          ),
                          Row(children: [
                            SizedBox(
                              height: 2.0 * scaleFactor,
                              width: (MediaQuery.of(context).size.width < 600) ? MediaQuery.of(context).size.width * 0.25 : 180.0,
                              child: const DecoratedBox(decoration: BoxDecoration(
                                color: Colors.blue
                              )),
                            ),
                            SizedBox(
                              height: 15.0 * scaleFactor,
                              width: 2.0 * scaleFactor,
                              child: const DecoratedBox(decoration: BoxDecoration(
                                color: Colors.blue
                              )),
                            ),
                            ],)
                        ],
                      ),
                    ),
                  ),
                  Expanded(child:
                      InkWell(
                        child:  SizedBox(
                          width: 100.0  * scaleFactor,
                          height: 100.0  * scaleFactor,
                          child: DecoratedBox(decoration:
                           BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2.0),
                            image: const  DecorationImage(
                              image: AssetImage('assets/images/google.png') 
                            )
                          ),)
                        ),
                        onTap: (){
                            //action code when clicked
                           googleLogin();
                        },
                      )
                  ),
                  SizedBox(height: 20.0  * scaleFactor),
                  SizedBox(
                    height: 65.0  * scaleFactor,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_logingIn)? Colors.grey: Colors.blue,
                        ),
                        onPressed: (){
                                //action code when clicked
                                if(!_logingIn){
                                  login(_active);
                                }
                        },
                        child: 
                          Text((_logingIn)? 'LOADING' :'LOG IN',
                          style : TextStyle(
                                fontSize: 16  * scaleFactor,
                                letterSpacing: 5.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                            ),
                          ),
                      ),
                  )
                ],
              ),
            )
          ] ,
        ),
      ),
    );
  }
}