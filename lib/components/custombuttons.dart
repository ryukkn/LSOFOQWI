import 'dart:convert';

import 'package:bupolangui/models/device.dart';
import 'package:bupolangui/models/student.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
              onLongPress!()
            },
            onPressed: ()=>{
              onPressed()
            },
            clipBehavior: Clip.antiAlias,
            style:  TextButton.styleFrom(
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
                    letterSpacing: 1.2 * scaleFactor,
                  ),)) ,
                  ),
              ),
              Padding(
                padding: const EdgeInsets.only(left : 20.0),
                child: Text(mainText,
                style: TextStyle(
                  color: (isActive) ? Colors.white: const Color.fromARGB(255, 247, 169, 53),
                  fontSize: 18 * scaleFactor,
                  fontWeight: (isActive)? FontWeight.w600 : FontWeight.w900,
                  letterSpacing: 2 * scaleFactor,
                ),
                                                  ),
              ),
            const Spacer(),
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

class DeviceButton extends StatelessWidget{
  final Device device;
  final Function editDevice;
  const DeviceButton({super.key, 
    required this.device,
    required this.editDevice,
  });

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
    return SizedBox(
      height: 60*scaleFactor,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: Color.fromARGB(255, 17, 108, 145),
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
                width: 200.0,
                child:  Center(
                  child: Text(device.name,
                    style:  TextStyle(
                      fontSize: 20*scaleFactor,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w400,
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
                          TextButton(
                            onPressed: ()=>{},
                            child: Icon(Icons.ad_units,
                              color: setStatus(device.systemUnit),
                            ),
                          ),
                          TextButton(
                            onPressed: ()=>{},
                            child: Icon(Icons.monitor,
                            color: setStatus(device.monitor),),
                          ),
                          TextButton(
                            onPressed: ()=>{},
                            child:  Icon(Icons.mouse,
                            color: setStatus(device.mouse),),
                          ),
                          TextButton(
                            onPressed: ()=>{},
                            child:  Icon(Icons.keyboard,
                            color: setStatus(device.keyboard),),
                          ),
                          TextButton(
                            onPressed: ()=>{},
                            child: Icon(Icons.power,
                              color: setStatus(device.avrups),
                            ),
                          ),
                          TextButton(
                            onPressed: ()=>{},
                            child: Icon(Icons.wifi,
                            color: setStatus(device.wifidongle),),
                          ),
                          TextButton(
                            onPressed: ()=>{
                              // dialogbox
                              editDevice()
                            },
                            child: const Icon(Icons.info),
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
  final account;
  const AccountButton({super.key, 
    required this.account
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
              Text(account.fullname, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
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
                width: 250.0,
                clipBehavior: Clip.antiAlias,
                decoration:const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color:Color.fromARGB(255, 202, 234, 255),
                  ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Row(
                        children: [
                          const Icon(Icons.email),
                          const SizedBox(width: 10),
                          Text(
                            account.email,
                            style: const TextStyle(fontWeight: FontWeight.w400)
                          ),
                        ],
                      ),
                    ),
                ),
                ),
              const SizedBox(width:5),
              SizedBox(width:40,
                  child: TextButton(
                  onPressed: ()=>{

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