import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bupolangui/models/verification.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
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

  final formKeys = [GlobalKey<FormState>(),GlobalKey<FormState>(),GlobalKey<FormState>(),GlobalKey<FormState>()];

  // final _streamController = StreamController.broadcast();
  // StreamSubscription? subscription;
  // ignore: unused_field
  Verification? _verification;

  String? _errorMessage;
  String? baseImage;
  final bool _pending = false;
  bool _signingIn = false;
  // Timer? _interval;
  // WebSocketChannel? channel;

  void setAccountType(int index) {
    setState(() {
      _active = index;
    });
  }

  Future pickImage() async{
     if(kIsWeb){
        setState(() {
          _errorMessage = "Uploading of profile is not supported on browsers";
        });
        return;
     } 
     final image = await ImagePicker()
          .pickImage(source: ImageSource.camera, maxWidth: 500, maxHeight: 500);
    if(image == null) return;

      List<int> imageBytes = File(image.path).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      setState(() {
        baseImage = baseimage;
      });
  }
    // Server Login
  Future signup(int priviledge) async{

    if(priviledge != 1 && priviledge != 3){
      setState(() {
        _errorMessage = "Pick an account type";
      });
      return;
    }
    var id = const Uuid().v4();
    var verification = Verification ( accountType: ((priviledge/3).round()+1).toString() ,id: id ,fullname: fullname.text, email: email.text, password: password.text, contact: contact.text);
    var url = Uri.parse("${Connection.host}flutter_php/request.php");
    setState(() {
      _signingIn = true;
    });
    var response = await server.post(url, body: {
        "id" : verification.id,
        "image": (baseImage != null) ? baseImage : "NULL",
        "accountType": verification.accountType,
        "email": verification.email,
        "fullname": verification.fullname,
        "contact" : verification.contact,
        "password" : verification.password
      });

    var data = json.decode(response.body);

    if(data['success']){
      // setState(() {
      //   _verification = verification;
      //   _pending = true;
      // });

      // _interval = Timer.periodic(const Duration(seconds: 1), (timer) async {
      //    var url_ = Uri.parse(Connection.host+"flutter_php/verification_check.php");
      //    var response_ = await server.post(url_, body: {
      //     "id" : verification.id,
      //    });
      //    var data_ = json.decode(response_.body);
      //    if(data_['verified']){
      //     registerAccount();
      //     _interval!.cancel();
      //     _interval = null;
      //     // ignore: use_build_context_synchronously
      //     Navigator.of(context).pop();
          
      //    }else{
      //     if(data_['message'] != "" &&  mounted){
      //       setState(() {
      //       _errorMessage = data_['message'];
      //       _pending = false;
      //     });
      //     }
      //    }
      //  });
      setState(() {
        _signingIn = false;
      });
      Navigator.of(context).pop();
    }else{
      setState(() {
        _signingIn = false;
        _errorMessage = data['message'];
      });
    }

    // WEBSOCKET
    // var url = Uri.parse(Connection.host+"flutter_php/validation.php");
    // var response = await server.post(url, body: {
    //   "email": email.text,
    //   "priviledge": priviledge.toString()
    // });
    // var data = json.decode(response.body);

    // if(data['success']){
    //   if(!_streamController.hasListener){
    //     channel = WebSocketChannel.connect(
    //       Uri.parse(Connection.socket), 
    //     );
    //   }

    //   try{
    //     await channel!.ready;
    //   }catch(e) {
    //     setState(() {
    //       _errorMessage = "Unable to connect to server";
    //     });
    //     return;
    //   }
    //   var id = const Uuid().v4();
    //   var verification = Verification ( accountType: ((priviledge/3).round()+1).toString() ,id: id ,fullname: fullname.text, email: email.text, password: password.text, contact: contact.text);
    //   var request = {
    //     "type" : "request",
    //     "data" : verification
    //   };
    //   setState(() {
    //     _verification = verification;
    //     _pending = true;
    //   });
    //   channel!.sink.add(jsonEncode(request));
    //   if(!_streamController.hasListener){
    //     _streamController.addStream(channel!.stream);
    //     _streamController.stream.listen((value) {
    //         var data = json.decode(value);
    //           if(data['verified']){
    //             registerAccount();
    //             Navigator.of(context).pop();
    //           }else{
    //             setState(() {
    //               _errorMessage = "Sign up rejected by admin.";
    //               _pending = false;
    //             });               
    //           }
    //       }  
    //     );
    //   }
    // }else{
    //   setState(() {
    //     _errorMessage = data['message'];
    //   });
    // }
  }



   @override
  void dispose() {
    super.dispose();
    // if(channel != null){
    //   channel!.sink.close();
    // }
    //  if(_interval != null){
    //     if(_interval!.isActive){
    //     _interval!.cancel();
    //   }
    // }
    fullname.dispose();
    email.dispose();
    password.dispose();
    contact.dispose();
    // _streamController.close();
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
                  SizedBox( height: 5.0  * scaleFactor ),
                  SizedBox(
                    height: 70.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: Form(
                        key: formKeys[0],
                        child: TextFormField(
                          controller: fullname,
                          validator: (value){
                            if(fullname.text.trim()==""){
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
                  ),
                  SizedBox(height: 20.0  * scaleFactor),
                  SizedBox(
                    height: 70.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: Form(
                            key: formKeys[1],
                        child: TextFormField(
                          
                          controller: email,
                          validator: (value){
                            final bool emailValid =
                                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[-a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(email.text);
                            if(email.text.trim()==""){
                              return "Field is Required";
                            }

                            if(!emailValid){
                              return "Must be a valid email.";
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
                  ),
                  SizedBox(height: 20.0  * scaleFactor),
                  SizedBox(
                    height: 70.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: Form(
                                 key: formKeys[2],
                        child: TextFormField(
                           inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ], 
                          keyboardType: TextInputType.number,
                          controller: contact,
                          validator: (value){
                            final bool isValidNumber = RegExp("^09[0-9]{9}\$")
                                      .hasMatch(contact.text);
  
                            if(contact.text.trim()==""){
                              return "Field is Required";
                            }
                            if(!isValidNumber){
                              return "Must be a valid 11-digit number (PH)";
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
                  ),
                  SizedBox(height: 20.0  * scaleFactor),
                  SizedBox(
                    height: 70.0 * scaleFactor,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                      child: Form(
                            key: formKeys[3],
                        child: TextFormField(
                          obscureText: true,
                          controller: password,
                          validator: (value){
                            if(password.text.trim()==""){
                              return "Field is Required";
                            }
                            if(password.text.trim().length < 8){
                              return "Password must be at least 8 characters";
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
                      Text( (baseImage != null) ? "Image uploaded" : 'Upload your picture',
                        style :TextStyle(
                              fontSize: 16  * scaleFactor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w400,
                              color:  (baseImage!= null) ? Colors.green :Colors.black,
                              ),
                      ),
                      SizedBox(height: 10.0  * scaleFactor),
                      InkWell(
                        child: Icon(Icons.image_search,
                          size: 60.0  * scaleFactor,
                        ),
                        onTap: (){
                            //action code when clicked
                            pickImage();
                        },
                      ),
                      SizedBox(height: 10.0  * scaleFactor),
                      Text( 'Upload here',
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
                    height: 65.0 *scaleFactor,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_signingIn) ? Colors.grey : Colors.blue,
                        ),
                        onPressed: (){
                                 if(!_signingIn) {

                                   bool validated = true;
                                    for (var formKey in formKeys) {
                                        if(!formKey.currentState!.validate()){
                                          validated =false;
                                        }
                                    }
                                  if (validated){
                                    signup(_active);
                                  }
                                 }
                               
                            },
                        child: 
                          Text((_signingIn) ? 'LOADING' :'SIGN UP',
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