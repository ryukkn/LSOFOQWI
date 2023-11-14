import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bupolangui/components/popups.dart';
import 'package:bupolangui/constants/constants.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/models/verification.dart';
import 'package:bupolangui/pages/stud/dart-js.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
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
  String? baseImage;
  final bool _pending = false;
  bool _signingIn = false;
  bool acceptedTerms = false;
 
  String? deviceToken;

  int attempt = 0;
  String? attemptErrorMessage;


  EmailOTP? myauth;

  @override
  void initState(){
    super.initState();
    myauth = EmailOTP();
    initializeFirebaseNotifications().then((value)async{
      if(mounted){
        deviceToken = value;
      }
    });
  }

  void setAccountType(int index) {
    setState(() {
      _active = index;
    });
  }
  
  Future pickImage(ImageSource source) async{
     if(kIsWeb){
        setState(() {
          showError(context, "Uploading of profile is not supported on browsers");
        });
        return;
     } 
     final image = await ImagePicker()
          .pickImage(source: source, maxWidth: 500, maxHeight: 500);
    if(image == null) return;

      List<int> imageBytes = File(image.path).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      setState(() {
        baseImage = baseimage;
      });
  }
    // Server Login
  Future signup(context,int priviledge) async{
    var id = const Uuid().v4();
    var verification = Verification ( accountType: ((priviledge/3).round()+1).toString() ,id: id ,fullname: fullname.text,
      email: email.text, password: password.text, contact: contact.text,
      deviceToken: deviceToken!
    );
    var url = Uri.parse("${Connection.host}flutter_php/request.php");
    var response = await server.post(url, body: {
        "id" : verification.id,
        "image": (baseImage != null) ? baseImage : "NULL",
        "accountType": verification.accountType,
        "email": verification.email,
        "fullname": verification.fullname,
        "contact" : verification.contact,
        "password" : verification.password,
        "devicetoken": verification.deviceToken
      });

    var data = json.decode(response.body);

    if(data['success']){
      setState(() {
        _signingIn = false;
      });
      Navigator.of(context).pop("Pending for verification, you will be notified once the account is verified.");
    }else{
      setState(() {
          _signingIn = false;
      });
      showError(context, data['message']);
    }

  }



   @override
  void dispose() {
    super.dispose();
    fullname.dispose();
    email.dispose();
    password.dispose();
    contact.dispose();
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
                  // SizedBox(height: 5.0  * scaleFactor),
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
                            
                            bool properCased = true;
                            var nameSplit = fullname.text.trim().split(" ");
                            nameSplit.forEach((name) { 
                              if(name.trim()==""){
                                properCased = false;
                                return;
                              }
                              if(name[0].trim().toUpperCase() != name[0].toString()){
                                properCased = false;
                                return;
                              }
                            });

                            if(!properCased){
                              return "Use proper case and spaces in writing name";
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
                                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@bicol-u.edu.ph$")
                                      .hasMatch(email.text);
                            // final bool IDValid =
                            //           RegExp("^[0-9]{4}-[0-9]{4}-[0-9]{5}\$")
                            //           .hasMatch(email.text);
                            if(email.text.trim()==""){
                              return "Field is Required";
                            }

                            if(!emailValid){
                              return "Must be a university email.";
                            }
                            var fullNameAsText = fullname.text.trim().replaceAll(".", "");
                            var nameSplit = fullNameAsText.split(" ");
                            var lastName = email.text.trim().split("@")[0].split(".")[1];
                            bool nameIsMatched = true;
                            bool hasLastName = false;
                            nameSplit.forEach((name) { 
                              if(!email.text.trim().toLowerCase().contains(name.toLowerCase())){
                                nameIsMatched = false;
                              }
                              if(lastName.toLowerCase() == name.toLowerCase()){
                                hasLastName = true;
                              }
                            });
                            if(!nameIsMatched || !hasLastName){
                              return "Must match at least your first and last name.";
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
                  SizedBox(height: 15*scaleFactor,),
                   Padding(
                      padding: EdgeInsets.only(left:40.0 * scaleFactor, right: 35*scaleFactor),
                     child: Row(children: [
                          SizedBox(
                            height: 15,
                            width: 15,                          
                            child: Checkbox(value: acceptedTerms, onChanged: (value){
                              setState(() {
                                acceptedTerms = value!;
                              });
                            })),
                          const SizedBox(width: 15,),
                          Expanded(
                            child: RichText(
                              // textAlign: TextAlign.justify,
                              text: TextSpan(
                              style: TextStyle(color: Colors.black,fontSize: 14*scaleFactor),
                              children: [
                              TextSpan(
                                text: "I have read and approved the application's "
                              ),
                              WidgetSpan(child: GestureDetector(
                                onTap: ()async{
                                  showDialog(context: context, builder: (context)=>SimpleDialog(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.height*0.6,
                                          width: (MediaQuery.of(context).size.width < 600.0) ? MediaQuery.of(context).size.width * 0.85 : 500.0,
                                          child: SingleChildScrollView(child: termsAndCondition)),
                                      )
                                    ],
                                  ));
                                },
                                child: Text("General Terms and Conditions", style: TextStyle(fontSize: 14*scaleFactor,color: Colors.blue, decoration: TextDecoration.underline),))),
                              TextSpan(text:"."),
                            ])),
                          )
                        ],),
                   ),
                  Expanded(child: Column(
                    children: [
                      SizedBox(height: 15.0  * scaleFactor),
                      Text( (baseImage != null) ? "Image uploaded" : 'Upload your picture',
                        style :TextStyle(
                              fontSize: 16  * scaleFactor,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w400,
                              color:  (baseImage!= null) ? Colors.green :Colors.black,
                              ),
                      ),
                      SizedBox(height: 10.0  * scaleFactor),
                      MenuAnchor(
                          builder:(BuildContext context, MenuController controller,Widget? child){
                            return InkWell(
                              onTap: (){
                                 if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                              },
                              child: Icon(Icons.add_a_photo, size: 42*scaleFactor,));
                          },
                          menuChildren: List<MenuItemButton>.generate(2, (index) => MenuItemButton(
                            child: Text((index==0)? "Use Camera" : "Browse Gallery"),
                            onPressed: () {
                            if(index == 0){
                              pickImage(ImageSource.camera);
                            }else{
                              pickImage(ImageSource.gallery);
                            }
                          },)),
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
                        onPressed: () async {
                                 if(!_signingIn) {
                                  if(_active != 1 && _active != 3){
                                     showError(context, "Pick an account type.");
                                    return;
                                  }
                                  setState(() {
                                    _signingIn = true;
                                  });
                                  bool validated = true;
                                  for (var formKey in formKeys) {
                                      if(!formKey.currentState!.validate()){
                                        validated =false;
                                      }
                                  }
                                  if(!validated){
                                    setState(() {
                                      _signingIn = false;
                                    });
                                  }
                                  if (validated){
                                    if(!acceptedTerms){
                                      showError(context, "You must accept terms and conditions.");
                                      setState(() {
                                        _signingIn = false;
                                      });
                                      return;
                                    }
                                    myauth!.setConfig(
                                      appEmail: "irishannediaz.salceda@bicol-u.edu.ph",
                                      appName: "CSD ComLab Monitoring",
                                      userEmail: email.text,
                                      otpLength: 4,
                                      otpType: OTPType.digitsOnly
                                    );
                                    await myauth!.sendOTP();
                                    setState(() {
                                      attempt = 0;
                                      attemptErrorMessage = null;
                                    });
                                    // ignore: use_build_context_synchronously
                                    var result = await showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      context: context, builder: (BuildContext context){
                                        return Container(
                                          height: 540*scaleFactor,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0))),
                                          child:  Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const Padding(
                                                padding:  EdgeInsets.only(top: 30.0, bottom:5.0),
                                                child:  Text("Enter verification code sent to your email", style: TextStyle(fontSize: 18),),
                                              ),
                                              VerificationCode(
                                                    autofocus: true,
                                                    digitsOnly: true,
                                                    textStyle: const TextStyle(fontSize: 20.0, color: Colors.blue),
                                                    keyboardType: TextInputType.number,
                                                    underlineColor: Colors.blue, // If this is null it will use primaryColor: Colors.red from Theme
                                                    length: 4,
                                                    cursorColor: Colors.blue, // If this is null it will default to the ambient
                                                    // clearAll is NOT required, you can delete it
                                                    // takes any widget, so you can implement your design
                                                    clearAll: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(
                                                        'Clear All',
                                                        style: TextStyle(fontSize: 16.0, color: Colors.blue[700]),
                                                      ),
                                                    ),
                                                    onCompleted: (String value)async{
                                                      bool verified = await myauth!.verifyOTP(
                                                        otp: value
                                                      );
                                                      if(!verified){
                                                        setState(() {
                                                          attempt += 1;  
                                                          attemptErrorMessage = "Incorrect verification code, try again ($attempt/3 attempts)";
                                                        });
                                                        if(attempt >= 3){
                                                          Navigator.of(context).pop("max_attempt");
                                                        }
                                                      }else{
                                                        signup(context, _active);
                                                      }                                                      
                                                    },
                                                    onEditing: (bool value) {
                                                    },
                                                  ),
                                              Text((attemptErrorMessage!=null) ? attemptErrorMessage! : "", style: const TextStyle(fontSize: 14, color: Colors.red),),
                                            ],
                                          ),
                                        );
                                    });
                                    setState(() {
                                      _signingIn = false;
                                    });
                                    if(result!=null){
                                      if(result == "max_attempt"){
                                        showError(context, "Maximum attempt exceeded re-try to generate new code");
                                      }else{
                                        Navigator.of(context).pop(result);
                                      }
                                    }
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