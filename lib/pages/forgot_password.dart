import 'dart:convert';

import 'package:bupolangui/pages/admin_dashboard.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/pages/studentview.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as server;
import 'package:bupolangui/functions/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController otp = TextEditingController();

  String? _promptMessage;
  bool _updating = false;
  EmailOTP? myauth;
  bool sentOTP = false;

  @override
  void initState() {
    super.initState();
    myauth = EmailOTP();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    otp.dispose();
    super.dispose();
  }

  bool sendingOTP = false;
  void sendOTP() async{
    if(email.text == ""){
      setState(() {
        _promptMessage = "Enter valid email address";
      });
      return;
    }
    setState(() {
      sendingOTP = true;
    });
    // check if email exists in accounts
    var url = Uri.parse("${Connection.host}flutter_php/email_exist.php");
    var response = await server.post(url, body: {
        "email" : email.text
      });

    var data = json.decode(response.body);

    if(data['success']){
      myauth!.setConfig(
        appEmail: "irishannediaz.salceda@bicol-u.edu.ph",
        appName: "CSD ComLab Monitoring",
        userEmail: email.text,
        otpLength: 6,
        otpType: OTPType.mixed
      );

      bool sent = await myauth!.sendOTP();
      if(!sent){
        setState(() {
          _promptMessage = "Error sending OTP, check email or connection";
          sendingOTP = false;
        });
      }else{
        setState(() {
        _promptMessage = "Check your email for OTP to reset your password";
          sentOTP = sent;
          sendingOTP = false;
        });
      }
    }else{
      setState(() {
        _promptMessage = "Not a registered email address";
        sendingOTP = false;
      });
    }
    
  }

  void changePassword() async{
    setState(() {
      _updating = true;
    });
    bool verified = await myauth!.verifyOTP(
      otp: otp.text
    );
    if(!verified){
      setState(() {
        _updating = false;
        _promptMessage = "Incorrect OTP";
      });
      return;
    }
    if(password.text.trim().length < 8){
      setState(() {
        _updating = false;
        _promptMessage = "Passwords must be at least 8 characters";
      });
      return;
    }
    var url = Uri.parse("${Connection.host}flutter_php/change_password.php");
    var response = await server.post(url, body: {
        "email" : email.text.trim(),
        "password" : password.text.trim()
      });
    setState(() {
       _updating = false;
    });
    var data = json.decode(response.body);
    if(!data['success']){
      setState(() {
        _promptMessage = "data['message']";
      });
    }else{
      Navigator.of(context).pop();
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
                        'Reset your password',
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
                  SizedBox(height: 30.0  * scaleFactor),
                  Expanded(
                    child: Column(children: [
                       SizedBox(
                          height: 70.0 * scaleFactor,
                          width: double.infinity,
                          child: Padding(
                            padding:EdgeInsets.symmetric(horizontal: 30.0 *scaleFactor),
                            child: TextFormField(
                              controller: email,
                              readOnly: sentOTP,
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
                        SizedBox(height: 10.0  * scaleFactor),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 35.0 *scaleFactor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 40*scaleFactor,
                                width: 120,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: (!sentOTP && !sendingOTP) ? Colors.blue: Colors.grey),
                                  child: Row(
                                  children: [
                                    Text((sendingOTP) ? "Sending.." : "Send OTP"),
                                    SizedBox(width:10*scaleFactor),
                                    Icon(Icons.send, size: 14*scaleFactor,)
                                  ],
                                ),onPressed: (){
                                  if(!sendingOTP && !sentOTP){
                                    sendOTP();
                                  }
                                },)),
                              SizedBox(width: 20*scaleFactor,),
                              Expanded(child: Center(child: Text((_promptMessage ==null) ? "" : _promptMessage!)))
                            ],
                          ),
                        ),
                        SizedBox(height: 30.0  * scaleFactor),
                        (!sentOTP) ? const SizedBox() : SizedBox(
                          height: 60.0 * scaleFactor,
                          width: double.infinity,
                          child: Padding(
                            padding:EdgeInsets.symmetric(horizontal: 30.0 *scaleFactor),
                            child: TextFormField(
                              controller: otp,
                              style: TextStyle(
                                      fontSize: 18  * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                ),
                                labelText: 'OTP',
                                
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0  * scaleFactor),
                        (!sentOTP) ? const SizedBox() : SizedBox(
                          height: 60.0 * scaleFactor,
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                            child: TextFormField(
                              obscureText: true,
                              controller: password,
                              style: TextStyle(
                                      fontSize: 18  * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                ),
                                labelText: 'New Password',
                              ),
                            ),
                          ),
                        ),
                    ],),
                  ), 
                  SizedBox(height: 20.0  * scaleFactor),
                  SizedBox(
                    height: 65.0  * scaleFactor,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_updating || !sentOTP)? Colors.grey: Colors.blue,
                        ),
                        onPressed: (){
                                //action code when clicked
                                if(!_updating && sentOTP){
                                  changePassword();
                                }
                        },
                        child: 
                          Text((_updating)? 'LOADING' :'RESET PASSWORD',
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