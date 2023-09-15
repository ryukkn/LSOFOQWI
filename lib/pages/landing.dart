import 'package:bupolangui/pages/login.dart';
import 'package:bupolangui/pages/signup.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.title});
  final String title;

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
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
        child:Column(
          children:[
              SizedBox(height: 60.0 * scaleFactor),
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
                          height: 70.0  * scaleFactor,
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
                        Center(
                          child: Text("Let's start!",
                            style: TextStyle(
                                      fontSize: 32 * scaleFactor,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 1.2,
                                      color: const Color.fromARGB(228, 255, 255, 255),
                                    ),
                          ),
                        )
                      ],
                    ),
              ),
              FittedBox(
                          fit: BoxFit.fitWidth,
                          child: SizedBox(
                            height: 40.0,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                // borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                // color: Color.fromARGB(255, 11, 95, 221),
                              ),
                              child:  Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Center(
                                  child: Text(
                                    'COMPUTER LABORATORY MONITORING APP',
                                    style: TextStyle(
                                      fontSize: 20  * scaleFactor,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),)
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
                            onPressed: (){
                                    //action code when clicked
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Signup(title: '',)));
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