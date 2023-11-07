



import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/pages/faculty_portal.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:bupolangui/pages/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

dashboardHeader(double scaleFactor,String title) => Column(children: [
    Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60 *scaleFactor,
                width: 500.0 * scaleFactor,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                     boxShadow: [
                      BoxShadow(
                        offset: Offset(1,3),
                        spreadRadius: 2,
                        blurRadius: 2,
                        color: Colors.black54
                      )
                    ],
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20)),
                    color: Color.fromARGB(239, 7, 67, 90)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right_rounded, size: 32.0, color: Colors.white),
                          const SizedBox(width: 20.0),
                          Text(title,
                            style: TextStyle(
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2 ,
                              color: Colors.white
                            ),),
                        ],
                      )
                      ),
                  ),
                  ),  
                ),
                 Padding(
                   padding: const EdgeInsets.only(left: 20.0),
                   child: SizedBox(
                      width: 150.0 * scaleFactor,
                      height: 150.0 * scaleFactor,
                      child: Image.asset('assets/images/bupolanguiseal.png',
                        isAntiAlias: true,
                      )
                    ),
                 ),
                 Expanded(child: SizedBox(
                   height: 130.0 * scaleFactor,
                   child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,                      
                        child: Text("",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 20 *scaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                   ),
                 )
                 )
            ],
          ),
],);


appBar(double scaleFactor,title, context,currentTab, back, account, {bool autoleading = false})=>AppBar(
              title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,letterSpacing: 1.5, fontSize: 20 * scaleFactor),),
              centerTitle: true,
              actions: [
                SizedBox(
                  width: 80.0*scaleFactor,
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
                                child: const Text("PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:()async{
                                   var accountUpdate =  await Navigator.push(
                                      context,
                                    PageRouteBuilder(
                                        pageBuilder: (context , anim1, anim2) =>
                                            ViewProfile(account: account)));
                                   if(accountUpdate!=null){
                                    account.fullname = accountUpdate.fullname;
                                    account.contact =accountUpdate.contact;
                                    if(account is Student){
                                      account.block = accountUpdate.block;
                                    }
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
                      )
                    },
                    child: const Icon(Icons.menu),
                  ),
                )
              ],
              automaticallyImplyLeading: autoleading,
              leading: (currentTab == 0) ? null : SizedBox(
                  width: 80.0*scaleFactor,
                  child: InkWell(
                    onTap: (){
                      back();
                    },
                    child: Icon(Icons.arrow_back, color:  (currentTab == 0) ? Colors.grey: Colors.white,),
                  ),
                )
            );


bottomNavigation (double scaleFactor, context,faculty, active)=> Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              height: 90*scaleFactor,
              child: Padding(
                padding: EdgeInsets.symmetric( horizontal: 10.0*scaleFactor ,vertical: 8.0),
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.black87,
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, -2), // changes position of shadow
                          )
                        ]
                ),
                child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.home,color:  (active==1) ? Colors.blue : Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                          Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  FacultyHome(faculty: faculty,)))
                      },),
                    ),
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.calendar_month,color:  (active==2) ? Colors.blue :Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                         Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  FacultyScheduling(faculty: faculty,)))
                      },),
                    ),
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.edit_note,color: (active==3) ? Colors.blue : Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                           Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  FacultyManageCourse(faculty: faculty,)))
                      },),
                    ),
                    SizedBox(
                      width: 60*scaleFactor,
                      height: double.infinity,
                      child: TextButton(child: Icon(Icons.qr_code_scanner,color: (active==4) ? Colors.blue : Colors.white, size: 40*scaleFactor,), onPressed: ()=>{
                        Navigator.pushReplacement(
                            context,
                          PageRouteBuilder(
                              pageBuilder: (context , anim1, anim2) =>
                                  TimeIn(faculty: faculty,)))
                      },),
                    ),
                  ]),
                ),
              )
              ),
          );


simpleTitleHeader(double scaleFactor, String mainText, String subText)=> Column(children: [
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
                TextSpan(text: "$mainText\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                TextSpan(text: "$subText\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
              ])),
            ),
          ),
        ),
          SizedBox(
            width: double.infinity,
            height: 20*scaleFactor,
            child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
          ),
],);

infoHeader(double scaleFactor, String mainText, String subText)=> Column(children: [
    SizedBox(
            width: double.infinity,
            height: 25*scaleFactor,
            child: const DecoratedBox(decoration: BoxDecoration(color: Color.fromARGB(255, 17, 77, 112),
            )),
          ),
          SizedBox(
          width: double.infinity,
          height: 90*scaleFactor,
          child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 247, 232, 222),
          ),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                TextSpan(text: "$mainText\n", style: TextStyle(height: 2.5,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                TextSpan(text: "$subText\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 16*scaleFactor, color: Colors.black)),
              ])),
            ),
          ),
        ),
          SizedBox(
            width: double.infinity,
            height: 20*scaleFactor,
            child:  const DecoratedBox(decoration: BoxDecoration(color:  Color.fromARGB(255, 17, 77, 112),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2.0,
                  spreadRadius: 2.0
                )
              ]
            )),
          ),
],);