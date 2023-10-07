
import 'package:bupolangui/components/dashboard_content.dart';
import 'package:bupolangui/pages/landing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {

  int _activeContent = 1;

  void setContent(int content){
    setState(() {
      _activeContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
   double scaleFactor = (MediaQuery.of(context).size.height/1000);
   const Color sideNavColor = Colors.white;
   const Color sideNavBColor = Colors.transparent;
   const Color sideNavIColor = Colors.orange; 
    return  Scaffold(
      resizeToAvoidBottomInset: false,
      body:(defaultTargetPlatform != TargetPlatform.android
          &&  MediaQuery.of(context).size.width /  MediaQuery.of(context).size.height < 1.77
      ) ? const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Admin interface is not supported on this resolution."),
        ],
      ),) :  Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover
          ),
        ),
        child: Center(child: Row(children: [
          SizedBox(

            width: MediaQuery.of(context).size.width * .05,
            
          ),
          /*---------- Sidebar --------- */
          Container(
            height: MediaQuery.of(context).size.height * .9,
            width: MediaQuery.of(context).size.width * .2,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color.fromARGB(218, 7, 66, 90),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child:  Column(
                children: [
                  SizedBox(
                        width: double.infinity,
                        height: 70 * scaleFactor,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 236, 127, 2)
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0 * scaleFactor),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                 InkWell(
                                  onTap: () => {},
                                  child: const Icon(Icons.person, color: Colors.white,),
                                 ),
                                 Text("Admin Dashboard",
                                          style: TextStyle(
                                      fontSize: 22 * scaleFactor,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                                        ),
                                                      ),
                                InkWell(
                                  onTap: () async {
                                    SharedPreferences prefs =  await SharedPreferences.getInstance();
                                      await prefs.remove('ID');
                                      await prefs.remove('Type');
                                     Navigator.pushReplacement(
                                                    context,
                                                  PageRouteBuilder(
                                                      pageBuilder: (context , anim1, anim2) =>
                                                          const LandingPage()));
                                  },
                                  child: const Icon(Icons.logout, color: Colors.white,),
                                 ),
                                ],
                              ),
                            ),
                          ),)
                      ),
                  Column(
                      children: [
                        SizedBox(height: 10.0 * scaleFactor,),
                        SizedBox(
                          height: 60.0 *scaleFactor,
                          width: double.infinity,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: sideNavBColor,
                                ),
                                onPressed: ()=>{
                                  setContent(1)
                                }, 
                                  child: Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 25.0*scaleFactor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children:[
                                      const Icon(Icons.computer_rounded,color: sideNavIColor),
                                      SizedBox(width: 20.0 * scaleFactor,),
                                      Text("Manage Laboratories",
                                      style: TextStyle(
                                        fontSize: 20 * scaleFactor,
                                        fontWeight: (_activeContent == 1) ? FontWeight.w600 : FontWeight.w500,
                                        color: sideNavColor
                                      ),
                                    ),
                                    ],),
                                  )
                                ),
                          )
                        ),                 
                         SizedBox(
                          height: 60.0 *scaleFactor,
                          width: double.infinity,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: sideNavBColor,
                                ),
                                onPressed: ()=>{
                                  setContent(2)
                                }, 
                                  child: Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 25.0*scaleFactor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children:[
                                      const Icon(Icons.people,color: sideNavIColor),
                                      SizedBox(width: 20.0 * scaleFactor,),
                                      Text("Manage Accounts",
                                      style: TextStyle(
                                        fontSize: 20 * scaleFactor,
                                        fontWeight: (_activeContent == 2) ? FontWeight.w600 : FontWeight.w500,
                                        color: sideNavColor
                                      ),
                                    ),
                                    ],),
                                  )
                                ),
                          )
                        ),       
                          SizedBox(
                          height: 60.0 *scaleFactor,
                          width: double.infinity,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: sideNavBColor,
                                ),
                                onPressed: ()=>{
                                  setContent(5)
                                }, 
                                  child: Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 25.0*scaleFactor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children:[
                                      const Icon(Icons.library_books,color: sideNavIColor),
                                      SizedBox(width: 20.0 * scaleFactor,),
                                      Text("Manage Courses",
                                      style: TextStyle(
                                        fontSize: 20 * scaleFactor,
                                        fontWeight: (_activeContent == 5) ? FontWeight.w600 : FontWeight.w500,
                                        color: sideNavColor
                                      ),
                                    ),
                                    ],),
                                  )
                                ),
                          )
                        ),               
                        SizedBox(
                          height: 60.0 * scaleFactor,
                          width: double.infinity,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: sideNavBColor,
                                ),
                                onPressed: ()=>{
                                  setContent(3)
                                }, 
                                  child: Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 25.0*scaleFactor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children:[
                                      const Icon(Icons.report,color: sideNavIColor),
                                      SizedBox(width: 20.0 * scaleFactor,),
                                      Text("Check Reports",
                                      style: TextStyle(
                                        fontSize: 20 * scaleFactor,
                                        fontWeight: (_activeContent == 3) ? FontWeight.w600 : FontWeight.w500,
                                        color: sideNavColor
                                      ),
                                    ),
                                    ],),
                                  )
                                ),
                          )
                        ),
                        SizedBox(
                          height: 60.0 * scaleFactor,
                          width: double.infinity,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: sideNavBColor,
                                ),
                                onPressed: ()=>{
                                  setContent(4)
                                }, 
                                  child: Padding(
                                    padding:EdgeInsets.symmetric(horizontal: 25.0*scaleFactor),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children:[
                                      const Icon(Icons.check_circle,color: sideNavIColor),
                                      SizedBox(width: 20.0 * scaleFactor,),
                                      Text("Sign Up Verification",
                                      style: TextStyle(
                                        fontSize: 20 * scaleFactor,
                                        fontWeight: (_activeContent == 4) ? FontWeight.w600 : FontWeight.w500,
                                        color: sideNavColor
                                      ),
                                    ),
                                    ],),
                                  )
                                ),
                          )
                        ),
                        
                      ]),
                      const Spacer(),  
                ]
          )),
          SizedBox(
            width: MediaQuery.of(context).size.width * .005,
          ),
          /*---------- Main Content--------- */
          Container(
            height: MediaQuery.of(context).size.height * .85,
            width: MediaQuery.of(context).size.width * .7,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color.fromARGB(228, 255, 255, 255),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: DashboardContent(content: _activeContent)
          ),
        ],
        ),)
      ),
    );
  }
}