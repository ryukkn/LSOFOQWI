
import 'package:bupolangui/components/popups.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/models/device.dart';
import 'package:bupolangui/models/session.dart';
import 'package:bupolangui/models/student.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bupolangui/models/report.dart';

class CategoryButton extends StatelessWidget{
  final String mainText;
  final String leftText;
  final String rightText;
  final bool isActive;
  final Function onPressed;
  final Function? onLongPress;
  final bool expandButton;
  final bool hasError;
  const CategoryButton({super.key, 
    required this.mainText,
    this.leftText = "",
    this.rightText = "",
    this.isActive = false,
    this.hasError = false,
    required this.onPressed,
    this.onLongPress,
    this.expandButton = false
  });

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return SizedBox(
      height: 60* scaleFactor,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: TextButton(
            onLongPress: ()=>{
              if(onLongPress != null) {
                onLongPress!()
              }
            },
            onPressed: ()=>{
              onPressed()
            },
            clipBehavior: Clip.antiAlias,
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: (expandButton) ? const Color.fromARGB(92, 143, 99, 45) : (hasError) ? Colors.red :(!isActive) ? const Color.fromARGB(255, 68, 46, 15) : const Color.fromARGB(255, 17, 108, 145),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            child: (expandButton) ? const Center(
              child: Icon(Icons.add,color: Colors.brown,),
            )
              : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              SizedBox(width: 60.0 * scaleFactor,
                height: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: (hasError) ? Colors.deepOrange :  (!isActive)  ? const Color.fromARGB(255, 48, 33, 12) : const Color.fromARGB(255, 10, 83, 112))  ,
                  child: Center(child: Text(leftText,
                    style: TextStyle(
                    color: const Color.fromARGB(207, 255, 255, 255),
                    fontSize: 14 * scaleFactor,
                    fontWeight: FontWeight.bold,
            
                  ),)) ,
                  ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left : 20.0),
                  child: Text(mainText,
                  style: TextStyle(
                    color: (isActive) ? Colors.white: const Color.fromARGB(255, 247, 169, 53),
                    fontSize: 17 * scaleFactor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                                                    ),
                ),
              ),
            SizedBox(width: 60.0 * scaleFactor,
                height: double.infinity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Center(child: Text(rightText,
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2 * scaleFactor,
                  ),)) ,
                  ),
              ),
            ],),
            ),
          ),
    );
  }
}


Color setStatus(String status){
    switch (status){
      case "F":
        return Colors.blue;
      case "NF":
        return Colors.orange;
      case "M":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

class DeviceButton extends StatelessWidget{
  final Device device;
  final Function editDevice;
  const DeviceButton({super.key, 
    required this.device,
    required this.editDevice,
  });

  Icon setType(String type){
    switch (type){
      case "PC":
        return const Icon(Icons.desktop_windows_outlined, color: Colors.white,);
      default:
        return const  Icon(Icons.laptop,color: Colors.white,);
    }
  }



  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    double screenWidth =   MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 65*scaleFactor,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration:  BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: (device.isDefective()) ? Colors.red :  const Color.fromARGB(255, 17, 108, 145),
          ),
          child: Row(
              children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: setType(device.type),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: 3.0 * scaleFactor,
                  child: const DecoratedBox(decoration: BoxDecoration(
                    color: Colors.black26
                  )),
                ),
              ),
              SizedBox(
                height: double.infinity,
                width: (screenWidth <= 1366) ? 180 *scaleFactor:  250.0 * scaleFactor,
                child:  Center(
                  child: Text(device.name,
                    style:  TextStyle(
                      fontSize: 18*scaleFactor,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      shadows:[
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    ),
                  ),
                ),
              ),
              TextButton(onPressed: ()=>{
                showDialog(context: context, 
                builder: (context) => AlertDialog(
                  content: SizedBox(
                    width: 500.0,
                    height: 500.0,
                    child: Center(
                        child: QrImageView(
                          data: device.QR!,
                          version: QrVersions.auto,
                          size:300.0
                        ),
                      ),
                  ),
                )
                )
              }, 
              child: Icon(Icons.qr_code,color: (device.QR != null)? Colors.white : Colors.grey ,)),
              Expanded(
                child: SizedBox(height: double.infinity,
                  child:  DecoratedBox(decoration: const  BoxDecoration(
                    color: Color.fromARGB(255, 48, 33, 12) 
                  ),
                    child: Padding(padding: const EdgeInsets.only(right: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{},
                              child: Icon(Icons.ad_units,
                              size: 24*scaleFactor,
                                color: setStatus(device.systemUnit,),
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{},
                              child: Icon(Icons.monitor,
                              size: 24*scaleFactor,
                              color: setStatus(device.monitor),),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{},
                              child:  Icon(Icons.mouse,
                              size: 24*scaleFactor,
                              color: setStatus(device.mouse),),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{},
                              child:  Icon(Icons.keyboard,
                              size: 24*scaleFactor,
                              color: setStatus(device.keyboard),),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{},
                              child: Icon(Icons.power,
                              size: 24*scaleFactor,
                                color: setStatus(device.avrups),
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{},
                              child: Icon(Icons.wifi,
                              size: 24*scaleFactor,
                              color: setStatus(device.wifidongle),),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: ()=>{
                                // dialogbox
                                editDevice()
                              },
                              child:  Icon(Icons.info,size: 24*scaleFactor,),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
              )
          ],),  
          )
          ),
    );
  }
}


class AccountButton extends StatelessWidget{
  final dynamic account;
  final Function delete;
  final Function save;
  final TextEditingController emailcontroller;
  final TextEditingController fullnamecontroller;
   final TextEditingController passwordcontroller;
  const AccountButton({super.key, 
    required this.account,
    required this.save,
    required this.delete,
    required this.emailcontroller,
    required this.fullnamecontroller,
    required this.passwordcontroller,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 50 * scaleFactor,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 3,
                blurRadius: 3,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children:[
              const Icon(Icons.person),
              const SizedBox(width:15),
              Expanded(child: SingleChildScrollView(
                scrollDirection:Axis.horizontal,
                child: Text(account.fullname, style: const TextStyle(fontWeight: FontWeight.w500)))),
              const SizedBox(width: 10,),
              (account is Student) ? SizedBox(width:40,
                  child: TextButton(
                  onPressed: ()=>{showDialog(context: context, 
                        builder: (context) => AlertDialog(
                        content: SizedBox(
                          width: 500.0,
                          height: 500.0,
                          child: Center(
                              child: QrImageView(
                                data: account.QR!,
                                version: QrVersions.auto,
                                size:300.0
                              ),
                            ),
                        ),
                      )
                    )
                  },
                  child: const Align(
                    alignment: Alignment.center,
                  child: Icon(Icons.qr_code, color:Colors.black),))
              ): const SizedBox(),
              Container(height: 35*scaleFactor,
                  width: 180.0,
                  clipBehavior: Clip.antiAlias,
                  decoration:const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color:Color.fromARGB(255, 202, 234, 255),
                    ),
                  child:Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                          child: Row(
                            children: [
                              const Icon(Icons.email),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection:Axis.horizontal,
                                  child: Text(
                                    account.email,
                                    style:  TextStyle(fontWeight: FontWeight.w400, fontSize:18*scaleFactor)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),
                  
                  ),
              
              const SizedBox(width:5),
              SizedBox(width:40,
                  child: TextButton(
                  onPressed: (){
                    emailcontroller.text = account.email;
                    fullnamecontroller.text = account.fullname;
                    passwordcontroller.text = "";
                    showDialog(context: context, builder: (context) => EditUser(account: account, delete: delete, save: save, email: emailcontroller, fullname: fullnamecontroller, password: passwordcontroller));
                  },
                  child: const Align(
                    alignment: Alignment.center,
                  child: Icon(Icons.info, color:Colors.black),))
              ),
            ]
          ),
        )
      ),
    );
  }
}


class FacultySelectButton extends StatelessWidget {
  final String label;
  final Function onPress;
  final Function onLongPress;
  final Widget icon;
  const FacultySelectButton({super.key, required this.label,required this.icon, required this.onPress, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return Padding(padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child:ElevatedButton(
          clipBehavior: Clip.antiAlias,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue,
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
          ),
          child: Row(children: [
            SizedBox(
              width: 50*scaleFactor,
              height: double.infinity,
              child: const DecoratedBox(decoration: BoxDecoration(color: Colors.blue),),
            ),
            SizedBox(width: 20*scaleFactor, ),
            Expanded(
              child: Text(label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 *scaleFactor),
              ),
            ),
            SizedBox(
              width: 50*scaleFactor,
              child: Center(child: icon),
            ),
            SizedBox(width: 10*scaleFactor, ),
        ]),
        onPressed: ()=>{
          onPress()
        },
        onLongPress: (){
          onLongPress();
        },
        ) 
        
        ),
    );
  }
}

class FacultyHistoryButton extends StatelessWidget {
  final Report report;
  final Function onSubmit;
  final Function onView;
  const FacultyHistoryButton({super.key, required this.report, required this.onSubmit, required this.onView});

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return Padding(padding: const EdgeInsets.symmetric( vertical: 8.0, horizontal: 5.0),
      child: SizedBox(
        width: double.infinity,
        height: 100.0,
        child:Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(1.0,2.0),
                blurRadius: 2.0,
                spreadRadius: 1.0
              )
            ]
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 45.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: (report.timeOut != null) ?  Colors.blue : Colors.orange),
                  child: Row(children: [
                        const SizedBox(width: 10.0,),
                        const Icon(Icons.calendar_month,color: Colors.white,),
                        const SizedBox(width: 5.0,),
                        Text("${parseDate(report.timeIn)} (${parseDay(report.timeIn).toUpperCase()}) , ${parseTime(report.timeIn)}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16*scaleFactor),
                        ),

                        ]),
                ),
              ),
              Expanded(
                child: Padding(padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex:2,
                        child: SizedBox(
                          width: 250.0,
                          height: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                            child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 194, 228, 243),
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                              child: Center(child: Text("${report.sessions!} Sessions")),
                            ),
                          ),)),
                      Flexible(
                        flex:1,
                        child: SizedBox(
                          width: 100.0,
                          child:  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                child: const FittedBox(child: Text("View")), onPressed: (){
                                  onView();
                                },),
                          ),
                            
                          )),
                      (report.timeOut != null) ? const SizedBox() :Flexible(
                        flex:1,
                        child: SizedBox(
                          width: 100.0,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                            child: ElevatedButton(
                                 style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                child: const FittedBox(child: Text("Submit")), onPressed: (){
                                  onSubmit();
                                },),
                          ),
                          ))
                  ],)
                ),
              )
            ],
          ),

        ) 
        
        ),
    );
  }
}


class SessionHistoryButton extends StatelessWidget {
  final Session session;
  final Report? report;
  final Function? onEdit;
  final String type;
  final bool isEditable;
  const SessionHistoryButton({super.key, required this.session, this.report,this.type="faculty",this.onEdit,this.isEditable =false});

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height / 1000;
    return Padding(padding: const EdgeInsets.symmetric( vertical: 8.0, horizontal: 5.0),
      child: SizedBox(
        width: double.infinity,
        height: 100.0,
        child:Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(1.0,2.0),
                blurRadius: 2.0,
                spreadRadius: 1.0
              )
            ]
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 45.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color:(report != null) ? (report!.timeOut != null) ?  Colors.black87 : Colors.orange : Colors.black87),
                  child: Row(children: [
                        const SizedBox(width: 10.0,),
                        (type=="student") ? const SizedBox():const Icon(Icons.person,color: Colors.white,),
                        const SizedBox(width: 5.0,),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text((type!="student") ? session.student : "${parseDate(session.timestamp)} ${parseTime(session.timestamp)}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16*scaleFactor),
                            ),
                          ),
                        ),
                        (type=="admin") ? const SizedBox() : const Icon(Icons.computer,color: Colors.white,),
                        const SizedBox(width: 5.0,),
                        Text((type!="admin") ? session.device :  "${parseDate(session.timestamp)} ${parseTime(session.timestamp)}",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 16*scaleFactor),
                          ),
                        const SizedBox(width: 10.0,),
                        ]),
                ),
              ),
              Expanded(
                child: Padding(padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex:2,
                        child: SizedBox(
                          width: 400.0,
                          height: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                            child: DecoratedBox(decoration: const BoxDecoration(color: Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                Icon(Icons.ad_units, color: setStatus(session.systemUnit!),),
                                Icon(Icons.monitor,  color: setStatus(session.monitor!),),
                                Icon(Icons.mouse, color: setStatus(session.mouse!),),
                                Icon(Icons.keyboard, color: setStatus(session.keyboard!),),
                                Icon(Icons.power, color: setStatus(session.avrups!),),
                                Icon(Icons.wifi, color: setStatus(session.wifidongle!),)
                              ],),
                            ),
                          ),)),
                     (report == null ) ? const SizedBox(): (report!.timeOut != null && isEditable) ? const SizedBox() :Flexible(
                        flex:1,
                        child: SizedBox(
                          width: 100.0,
                          child:Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                            child: ElevatedButton(
                                 style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                child: const FittedBox(child: Text("Edit")), onPressed: (){
                                  if(onEdit != null){
                                    onEdit!();
                                  }
                                },),
                          ),
                          ))
                  ],)
                ),
              )
            ],
          ),

        ) 
        
        ),
    );
  }
}