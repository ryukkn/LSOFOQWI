import 'dart:async';
import 'dart:convert';

import 'package:bupolangui/models/verification.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as server;

class Signup extends StatefulWidget {
  const Signup({super.key, required this.title});
  final String title;

  @override
  State<Signup> createState() => _Signup();
}

class _Signup extends State<Signup> {
  int _active = 0;
  TextEditingController fullname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController password = TextEditingController();

  final _streamController = StreamController.broadcast();
  StreamSubscription? subscription;
  // ignore: unused_field
  Verification? _verification;

  String? _errorMessage;
  bool _pending = false;
  
  WebSocketChannel? channel;
  
  get http => null;

  void setAccountType(int index) {
    setState(() {
      _active = index;
    });
  }

    // Server Login
  Future signup(int priviledge) async{
    var url = Uri.http(Connection.host,"flutter_php/validation.php");
    var response = await server.post(url, body: {
      "email": email.text,
      "priviledge": priviledge.toString()
    });
    var data = json.decode(response.body);

    if(data['success']){
      channel ??= WebSocketChannel.connect(
        Uri.parse(Connection.socket), 
      );
      var id = const Uuid().v4();
      var verification = Verification ( accountType: ((priviledge/3).round()+1).toString() ,id: id ,fullname: fullname.text, email: email.text, password: password.text, contact: contact.text);
      var request = {
        "type" : "request",
        "data" : verification
      };
      setState(() {
        _verification = verification;
        _pending = true;
      });
      channel!.sink.add(jsonEncode(request));
      if(!_streamController.hasListener){
        _streamController.addStream(channel!.stream);
        _streamController.stream.listen((value) {
        var data = json.decode(value);
          if(data['verified']){
            registerAccount();
            Navigator.of(context).pop();
          }else{
            setState(() {
              _errorMessage = "Sign up rejected by admin.";
              _pending = false;
            });               
          }
      });
      }
    }else{
      setState(() {
        _errorMessage = data['message'];
      });
    }
  }

  void registerAccount() async{
    var url = Uri.http(Connection.host,"flutter_php/signup.php");
    var response = await server.post(url, body: {
      "fuilname": _verification!.fullname,
      "email": _verification!.email,
      "contact": _verification!.contact,
      "password": _verification!.password,
      "priviledge": _verification!.accountType,
    });
    var data = json.decode(response.body);

    if(!data['success']){
      setState(() {
        _pending = false;
        _errorMessage = data['message'];
      });
    }
  }

   @override
  void dispose() {
    super.dispose();
    if(channel != null){
      channel!.sink.close();
    }
    fullname.dispose();
    email.dispose();
    password.dispose();
    contact.dispose();
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    double scaleFactor = (MediaQuery.of(context).size.height/1000);
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover
          ),
        ),
        child: Column(
          children:[
              SizedBox(
              height: 30.0 * scaleFactor,
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
              child:  (_pending) ?  const Center(
                child:  Text("Waiting for Verification..."),
              ) : Column(
                children: [
                  SizedBox(height: 20.0 * scaleFactor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      SizedBox(width: 40.0 * scaleFactor, height: 40.0 * scaleFactor,
                        child: Center(child: TextButton(onPressed: () => {Navigator.pop(context)}, 
                        child: Icon(Icons.arrow_back, color: Colors.black,
                          size: 24.0 * scaleFactor,                        
                        ),)),
                      ),
                      Center(
                        child: Text(
                        'Sign up as',
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
                  SizedBox(height: 5.0  * scaleFactor),
                  Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0  * scaleFactor),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => {
                                  setAccountType(1)
                                },
                                style: TextButton.styleFrom(backgroundColor: (_active == 1) ? Colors.orange  : Colors.transparent),
                                child: Text(
                                'FACULTY',
                                  style: TextStyle(
                                    fontSize: 20  * scaleFactor,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1.2  * scaleFactor,
                                    color: (_active == 1) ? Colors.white :Colors.blue,
                                    ),
                                ),
                              ),
                              TextButton(
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
                              ),
                            ],
                          ),
                        ),
                      )
                    ),
                  SizedBox( height: 10.0  * scaleFactor ),
                  SizedBox(
                    height: 60.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: TextFormField(
                        controller: fullname,
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
                          labelText: 'Fullname',
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
                        controller: contact,
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
                          labelText: 'Contact Number',
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
                    height: 20.0 * scaleFactor,
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
                        const SizedBox(),
                      ],)
                    ),
                  ),
                  Expanded(child: Column(
                    children: [
                      SizedBox(height: 20.0  * scaleFactor),
                      Text('Upload your picture',
                        style :TextStyle(
                              fontSize: 16  * scaleFactor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              ),
                      ),
                      SizedBox(height: 10.0  * scaleFactor),
                      InkWell(
                        child: Icon(Icons.image_search,
                          size: 60.0  * scaleFactor,
                        ),
                        onTap: (){
                            //action code when clicked
                            print("The icon is clicked");
                        },
                      ),
                      SizedBox(height: 10.0  * scaleFactor),
                      Text('Upload here',
                        style :TextStyle(
                              fontSize: 12  * scaleFactor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              ),
                      ),
                    ],
                  )),
                  SizedBox(
                    height: 65.0  * scaleFactor,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: (){
                                //action code when clicked
                                signup(_active);
                            },
                        child: 
                          Text('SIGN UP',
                          style :TextStyle(
                                fontSize: 16  * scaleFactor,
                                letterSpacing: 5.0,
                                fontWeight: FontWeight.w600,
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