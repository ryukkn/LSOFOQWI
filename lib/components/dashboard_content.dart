
import 'dart:async';
import 'dart:convert';

import 'package:bupolangui/components/custombuttons.dart';
import 'package:bupolangui/models/device.dart';
import 'package:bupolangui/models/laboratory.dart';
import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/models/verification.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as server;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:web_socket_channel/status.dart' as status;

// ignore: must_be_immutable
class DashboardContent extends StatefulWidget {
  DashboardContent({super.key, required this.content});
  int? content;

  @override
  State<DashboardContent> createState() => _DashboardContent();
}


class _DashboardContent extends State<DashboardContent> {
  List<Laboratory> laboratories = [
    // Laboratory(id: "1", building: "B2", room: "101", units: 22),
    // Laboratory(id: "2", building: "B2", room: "204", units: 30),
    // // add dummy laboratory for plus button
    // Laboratory(id: "0", building: "0", room:  "0", units: 0),
  ] ;

  List<String> accountTypes = [
    "Admins", "Faculties", "Students"
  ];
  List<Student> students = [];

  List<Device> devices =[
    // Device(id: "1", labID: "1", name: "PC-001", QR: "pc--1", wifidongle: "N/A", mouse: "NF", monitor: "NF"),
    // Device(id: "2", labID: "1",name: "PC-002", QR: "pc--2", wifidongle: "N/A",),
    // Device(id: "3", labID: "1",name: "PC-003", QR: "pc--3", wifidongle: "N/A",),
    // Device(id: "4", labID: "1",name: "PC-004", QR: "pc--4", wifidongle: "N/A", monitor: "M", keyboard: "NF"),
    // Device(id: "5", labID: "1",name: "PC-005", QR: "pc--5", wifidongle: "N/A",monitor: "N/A",keyboard: "N/A",mouse: "N/A",systemUnit: "N/A",avrups: "NF"),
  ];

  TextEditingController building = TextEditingController();
  TextEditingController room = TextEditingController();
  TextEditingController prefix = TextEditingController();
  TextEditingController startIndex = TextEditingController();
  TextEditingController noOfDevices = TextEditingController();

  WebSocketChannel? channel;
  String? errorMessage;

  final _streamController = StreamController.broadcast();

  int _activeLab = 0;
  int _activeCategory = 0;

  var accounts = [];


  void openLab (int selected) async{
    var url = Uri.http(Connection.host,"flutter_php/admin_openLab.php");
    var response = await server.post(url, body: {
      "LabID" : laboratories[selected-1].id
    });
    var data = json.decode(response.body);

    if(data['success']){
      var rows = data['rows'];
      List<Device> loadedDevices = [];
      rows.forEach((dynamic row) => {
        loadedDevices.add(decodeDevice(row))
      });
      setState(() { 
        devices = loadedDevices;
        _activeLab = selected;
      });
    }else{
      print(data['message']);
    }

  }

  void createLab() async{
    var url = Uri.http(Connection.host,"flutter_php/admin_createlab.php");
    var response = await server.post(url, body: {
      "building": building.text,
      "room": room.text,
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      print(data['message']);
    }else{
      loadLabs();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  void loadLabs() async{
    var url = Uri.http(Connection.host,"flutter_php/admin_getLabList.php");
    var response = await server.get(url);
    var data = json.decode(response.body);

    if(data['success']){
      var rows = data['rows'];
      List<Laboratory> loadedLabs = [];
      rows.forEach((dynamic row) => {
      loadedLabs.add(decodeLaboratory(row))
      });
      setState(() {
        laboratories = loadedLabs;
      });
    }else{
      print(data['message']);
    }
  }

  Future getLab(String id) async{
    var url = Uri.http(Connection.host,"flutter_php/getlab.php");
    var response = await server.post(url, body: {
      "id": id,
    });

    var data = json.decode(response.body);

    return decodeLaboratory(data['row']);
  }

  void changeLabName(String id) async{

    var url = Uri.http(Connection.host,"flutter_php/admin_changelabname.php");
    var response = await server.post(url, body: {
      "id": id,
      "building": building.text,
      "room": room.text
    });
    var data = json.decode(response.body);

    if(data['success']){
      loadLabs();
      setState(() {
        _activeLab = 0;
      });
    }else{
      print(data['message']);
    }

  }

  void delete(String id , String from) async{
    var url = Uri.http(Connection.host,"flutter_php/delete.php");
    var response = await server.post(url, body: {
      "id": id,
      "from": from
    });
    print(response.body);
    var data = json.decode(response.body);

    if(data['success']){
      loadLabs();
      if(from == "laboratories" || _activeLab == 0){
        setState(() {
          _activeLab = 0;
        });
      }else{
        openLab(_activeLab);
      }
    }else{
      print(data['message']);
    }

  }

  void createDevices() async {
    var url = Uri.http(Connection.host,"flutter_php/admin_createdevices.php");
    var response = await server.post(url, body: {
      "prefix": prefix.text,
      "startIndex": startIndex.text,
      "noOfDevices": noOfDevices.text,
      "labID": laboratories[_activeLab-1].id,
    });

    var data = json.decode(response.body);
    
    if(!data['success']){
      print(data['message']);
    }else{
      openLab(_activeLab);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  void setActive(int selected){
    setState(() {
      _activeCategory = selected;
    });
  }

  void loadAccounts () async{
    var url = Uri.http(Connection.host,"flutter_php/admin_accounts.php");
    var response = await server.post(url, body: {
      "type" : _activeCategory.toString(),
    });
    var data = json.decode(response.body);

    if(data['success']){
      var rows = data['rows'];
      var loadedAccounts = [];
      switch(_activeCategory){
        case 1:
          rows.forEach((dynamic row) => {
          loadedAccounts.add(decodeAdmin(row))
        });
        break;
         case 2:
          rows.forEach((dynamic row) => {
          loadedAccounts.add(decodeFaculty(row))
        });
        break;
         case 3:
          rows.forEach((dynamic row) => {
          loadedAccounts.add(decodeStudent(row))
        });
        break;
        default:
          print("Invalid type");
      }
      setState(() {
        accounts = loadedAccounts;
      });
    }else{
      print(data['message']);
    }

  }

  void moveDevice(Device device) async{
    var url = Uri.http(Connection.host,"flutter_php/admin_movedevice.php");
    var response = await server.post(url, body: {
      "id" : device.id,
      "labID" : device.labID,
    });
    var data = json.decode(response.body);
    if(data['success']){
      loadLabs();
      openLab(_activeLab);
    }else{
      print(data['message']);
    }
  }

  void verify(String id){
    channel!.sink.add(
      json.encode({
        "type" : "verify",
        "id" : id
      })
    );
  }

  void reject(String id){
    channel!.sink.add(
      json.encode({
        "type" : "reject",
        "id" : id
      })
    );
  }
   void deleteAllRequests(int priviledge){
    channel!.sink.add(
      json.encode({
        "type" : "deleteallrequests",
        "category" : priviledge.toString(),
      })
    );
  }

  void refresh() async{
    if(channel != null){
      channel!.sink.close();
    }
    channel = WebSocketChannel.connect(
        Uri.parse(Connection.socket), 
    );
    try{
      await channel!.ready;
      setState(() {
        errorMessage = null;
      });
    }catch(e){
      setState(() {
        errorMessage = "Unable to connect  to the server.";
      });
      return;
    }
    _streamController.addStream(channel!.stream);
    channel!.sink.add(
      json.encode({
        "type" : "getrequests",
      })
    );
  }



  @override
  void initState() {
    super.initState();
    loadLabs();

  }

  @override
  void dispose(){
    super.dispose();
    if(channel!=null){
      channel!.sink.close();
    }
    building.dispose();
    room.dispose();
    prefix.dispose();
    startIndex.dispose();
    noOfDevices.dispose();
    _streamController.close();
  }
  @override
  Widget build(BuildContext context) {
    double  scaleFactor = MediaQuery.of(context).size.height / 1000;
    // ignore: unused_local_variable
    Color primaryColor  = const Color.fromARGB(238, 7, 81, 110);
    switch(widget.content){
      case 1:
        return Column(
        children: [
          SizedBox(height: 15 * scaleFactor,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60 *scaleFactor,
                width: 500.0 * scaleFactor,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20)),
                    color: Color.fromARGB(239, 7, 67, 90)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right_rounded, size: 32.0, color: Colors.white),
                          SizedBox(width: 20.0),
                          Text("Bicol University Laboratories",
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
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 40.0, right: 30.0 * scaleFactor,bottom: 40),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SizedBox(width: 450 *scaleFactor,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: ListView.builder(
                            padding: EdgeInsets.only(right: 30.0 * scaleFactor),
                            itemCount: laboratories.length+1,
                            itemBuilder: (context, int index){
                              return  CategoryButton(mainText:(index < laboratories.length)? "${laboratories[index].building} - ${laboratories[index].room}" : "", 
                                  leftText: (index < laboratories.length) ? "${laboratories[index].units}" : "",  
                                  isActive: (_activeLab == index+1),
                                  expandButton: (index == laboratories.length),
                                  onLongPress: (){
                                    if(index!=laboratories.length) {
                                      building.text = laboratories[index].building;
                                      room.text = laboratories[index].room;
                                      showDialog(
                                      context: context,
                                      builder:(context) => AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        clipBehavior: Clip.antiAlias,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text("Edit Laboratory"),
                                             SizedBox(
                                                  height: 35 * scaleFactor,
                                                  width:120.0,
                                                  child: DecoratedBox(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                      color: Colors.red
                                                    ),
                                                    child: FittedBox(
                                                      fit : BoxFit.contain,
                                                      child: TextButton(onPressed: () async{
                                                        await showDialog(context: context, 
                                                        builder: (context) => AlertDialog(
                                                          title: const Text("Are you sure you want to delete this laboratory and its contents?") ,
                                                          actions:[
                                                            TextButton(onPressed: (){
                                                              delete(laboratories[index].id, "laboratories");
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Delete")),
                                                            TextButton(onPressed: (){
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Cancel"))
                                                          ]
                                                        )
                                                        );
                                                        // ignore: use_build_context_synchronously
                                                        Navigator.of(context).pop();
                                                      }, 
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(5.0),
                                                          child: Text("Delete Laboratory", style: TextStyle(color: Colors.white),),
                                                        )
                                                      ),
                                                    ),
                                                  ),
                                                ),  
                                          ],
                                        ),
                                        content: SizedBox(
                                          width: 500,
                                          height: 300.0,
                                          child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                Expanded(child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Center(child:
                                                    Column(
                                                      children: [
                                                        SizedBox(height: 10.0 *scaleFactor,),
                                                        TextFormField(
                                                          controller: building,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                            ),
                                                            labelText: "Building Name",
                                                          ),
                                                        ),
                                                        SizedBox(height: 20.0 *scaleFactor,),
                                                        TextFormField(
                                                          controller: room,
                                                          decoration: const InputDecoration(
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                            ),
                                                            labelText: "Room",
                                                            hintText: "e.g 101",
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ),
                                                )),
                                                SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                                  child: DecoratedBox(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.deepOrange,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: [
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed: (){
                                                            changeLabName(laboratories[index].id);
                                                            Navigator. of(context). pop();
                                                          },
                                                          child: Text("Save",
                                                            style: TextStyle(
                                                              color:Colors.white,
                                                              fontSize: 20*scaleFactor
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: TextButton(
                                                          onPressed: ()=>{
                                                              Navigator. of(context). pop()
                                                          },
                                                          child: Text("Close",
                                                          style: TextStyle(
                                                              color:Colors.white,
                                                              fontSize: 20*scaleFactor
                                                            ),),
                                                        ),
                                                      )
                                                    ]),
                                                  ),
                                                )
                                              ],)
                                        ),
                                      )
                                    );
                                    }
                                  },
                                  onPressed: ()=>{
                                    if(index != laboratories.length){
                                        openLab(index+1)
                                      }else{
                                        showDialog(context: context, 
                                            builder: (context) => AlertDialog(
                                              title: const Text("Add New Laboratory"),
                                              contentPadding: EdgeInsets.zero,
                                              clipBehavior: Clip.antiAlias,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                              content: SizedBox(
                                                width: 500.0,
                                                height: 300.0,
                                                child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                      Expanded(child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(child:
                                                          Column(
                                                            children: [
                                                              SizedBox(height: 10.0 *scaleFactor,),
                                                              TextFormField(
                                                                controller: building,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Building Name",
                                                                  hintText: "e.g Building 2",
                                                                ),
                                                              ),
                                                              SizedBox(height: 20.0 *scaleFactor,),
                                                              TextFormField(
                                                                controller: room,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Room",
                                                                  hintText: "e.g 101",
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ),
                                                      )),
                                                      SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                                        child: DecoratedBox(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.deepOrange,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: [
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: ()=>{
                                                                  createLab()
                                                                },
                                                                child: Text("Add",
                                                                  style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: ()=>{
                                                                   Navigator. of(context). pop()
                                                                },
                                                                child: Text("Cancel",
                                                                style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),),
                                                              ),
                                                            )
                                                          ]),
                                                        ),
                                                      )
                                                    ],)
                                              ),
                                            )
                                            )
                                      }
                                  });
                            }
                            )
                          ),
                      ),
                      SizedBox(width: 0 *scaleFactor,),
                      Padding(padding: const EdgeInsets.only(bottom: 60.0),
                        child: SizedBox(width: 3 * scaleFactor,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:  Color.fromARGB(61, 92, 94, 95),))
                        ),
                      ),
                      SizedBox(width: 30 *scaleFactor,),
                      Expanded(
                        child: Padding(padding:EdgeInsets.only(right: 0.0 * scaleFactor,top: 20.0),
                         child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                SizedBox(height: 50.0 *scaleFactor, width: 350.0 * scaleFactor,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Search Device",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0)))
                                      )
                                    ),
                                ),
                                Padding(padding: const EdgeInsets.only(left: 20.0),
                                  child: TextButton(
                                    onPressed: ()=>{
                                       if(_activeLab != 0) showDialog(context: context, 
                                            builder: (context) => AlertDialog(
                                              title: const Text("Add Devices"),
                                              contentPadding: EdgeInsets.zero,
                                              clipBehavior: Clip.antiAlias,
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
                                              content: SizedBox(
                                                width: 500.0,
                                                height: 300.0,
                                                child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                      Expanded(child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(child:
                                                          Column(
                                                            children: [
                                                              SizedBox(height: 10.0 *scaleFactor,),
                                                              TextFormField(
                                                                controller: prefix,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Prefix Name",
                                                                  hintText: "e.g PC"
                                                                ),
                                                              ),
                                                              SizedBox(height: 20.0 *scaleFactor,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SizedBox(
                                                                width: 120.0,
                                                                child: TextFormField(
                                                                controller:  startIndex,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "Start Index",
                                                                  hintText: "e.g 1",
                                                                ),
                                                              ),
                                                              ),
                                                              Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                child: Icon(Icons.add, size: 32.0 * scaleFactor,),
                                                              ),
                                                              SizedBox(
                                                                width: 250.0,
                                                                child: TextFormField(
                                                                controller: noOfDevices,
                                                                decoration: const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                  ),
                                                                  labelText: "No. of Devices",
                                                                  hintText: "e.g 15 (PC-001 to PC-015)",
                                                                ),
                                                              ),
                                                              )
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                        ),
                                                      )),
                                                      SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                                        child: DecoratedBox(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.deepOrange,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: [
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: ()=>{
                                                                  createDevices()
                                                                },
                                                                child: Text("Add",
                                                                  style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: TextButton(
                                                                onPressed: ()=>{
                                                                   Navigator. of(context). pop()
                                                                },
                                                                child: Text("Cancel",
                                                                style: TextStyle(
                                                                    color:Colors.white,
                                                                    fontSize: 20*scaleFactor
                                                                  ),),
                                                              ),
                                                            )
                                                          ]),
                                                        ),
                                                      )
                                                    ],)
                                              ),
                                            )
                                            )
                                    },
                                    child: Row(children: [
                                      Icon(Icons.devices,
                                        color: (_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text("Add Devices" ,
                                        style: TextStyle(color:(_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ))
                                    ]),
                                  ),
                                ),
   
                                TextButton(
                                    onPressed: ()=>{
                                    },
                                    child: Row(children: [
                                      Icon(Icons.devices,
                                        color: (_activeLab == 0) ? Colors.grey : Colors.red,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text("View Defectives" ,
                                        style: TextStyle(color:(_activeLab == 0) ? Colors.grey : Colors.red,
                                      ))
                                    ]),
                                  ),
                                TextButton(
                                    onPressed: ()=>{
                                    },
                                    child: Row(children: [
                                      Icon(Icons.devices,
                                        color: (_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text("Print QRs" ,
                                        style: TextStyle(color:(_activeLab == 0) ? Colors.grey : Colors.blue,
                                      ))
                                    ]),
                                  ),
                              ],
                            ),
                            Expanded(child: (devices.isEmpty && _activeLab != 0)? const Center(
                                child: Text("No devices in this laboratory"),
                              ) :
                              ListView.builder(
                              padding: EdgeInsets.only(right: 10.0 * scaleFactor, top: 10.0),
                              itemCount: devices.length,
                              itemBuilder: (context, int index){
                                return DeviceButton(device: devices[index],
                                    editDevice: () {
                                      showDialog(context: context, 
                                       builder:(context) => AlertDialog(
                                        clipBehavior: Clip.antiAlias,
                                        contentPadding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                        title: SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(devices[index].name),
                                              SizedBox(width:20.0 *scaleFactor),
                                              SizedBox(
                                                  height: 35 * scaleFactor,
                                                  width:120.0,
                                                  child: DecoratedBox(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                      color: Colors.red
                                                    ),
                                                    child: FittedBox(
                                                      fit : BoxFit.contain,
                                                      child: TextButton(onPressed: ()async{
                                                        await showDialog(context: context, 
                                                        builder: (context) => AlertDialog(
                                                          title: const Text("Are you sure you want to remove this device?") ,
                                                          actions:[
                                                            TextButton(onPressed: (){
                                                              delete(devices[index].id, "devices");
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Delete")),
                                                            TextButton(onPressed: (){
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Cancel"))
                                                          ]
                                                        )
                                                        );
                                                        // ignore: use_build_context_synchronously
                                                        Navigator.of(context).pop();
                                                      }, 
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(5.0),
                                                          child: Text("Delete Device", style: TextStyle(color: Colors.white),),
                                                        )
                                                      ),
                                                    ),
                                                  ),
                                                ),  
                                            ],
                                          ),
                                        ),
                                        content: SizedBox(
                                          width: 600.0,
                                          height: 350.0,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: 10*scaleFactor,),
                                                      Row(children: [
                                                        SizedBox(
                                                          height: 50.0 *scaleFactor,
                                                          width: 300.0,
                                                          child: TextFormField(
                                                          enabled:false,
                                                          initialValue: (devices[index].lastSession != null) ? devices[index].lastSession!.student!.fullname : "None",
                                                          decoration: const InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                                labelText: "Last User",
                                                              ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 20*scaleFactor),
                                                        SizedBox(
                                                          height: 50.0 *scaleFactor,
                                                          width: 170.0,
                                                          child: TextFormField(
                                                          enabled: false,
                                                          initialValue: (devices[index].lastSession != null) ? devices[index].lastSession!.date! : "None",
                                                          decoration: const InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                                labelText: "Last Session",
                                                              ),
                                                          ),
                                                        )
                                                      ],),
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 15.0 * scaleFactor),
                                                          child: SizedBox(
                                                            height: 45 * scaleFactor,
                                                            width: 140.0,
                                                            child: DecoratedBox(
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                color: Colors.blue
                                                              ),
                                                              child: FittedBox(
                                                                fit : BoxFit.contain,
                                                                child: TextButton(onPressed: ()=>{}, 
                                                                  child: const Padding(
                                                                    padding: EdgeInsets.all(10.0),
                                                                    child: Text("View History", style: TextStyle(color: Colors.white),),
                                                                  )
                                                                ),
                                                              ),
                                                            ),
                                                          ),  
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15*scaleFactor,
                                                      ),
                                                      Row(children: [
                                                        SizedBox(
                                                          height: 50.0 *scaleFactor,
                                                          width: 140.0,
                                                          child: TextFormField(
                                                          readOnly: true,
                                                          textAlign: TextAlign.center,
                                                          initialValue: "Laboratory",
                                                          decoration: const InputDecoration(
                                                                border: OutlineInputBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                                                ),
                                                              ),
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                          child: Center(child: Icon(Icons.arrow_right)),
                                                        ),
                                                        DropdownMenu(
                                                          width: 250.0,
                                                          initialSelection: laboratories[_activeLab-1].id,
                                                          onSelected: (String? value)=>{
                                                            setState(() {
                                                              devices[index].labID = value!;
                                                            })
                                                          },
                                                          dropdownMenuEntries: laboratories.map<DropdownMenuEntry<String>>((Laboratory laboratory) {
                                                            return DropdownMenuEntry<String>(value: laboratory.id, label: "${laboratory.building} - ${laboratory.room}");
                                                          }).toList(),
                                                        )

                                                      ],),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 70.0*scaleFactor, width: double.infinity,
                                              child: DecoratedBox(
                                                decoration: const BoxDecoration(
                                                  color: Colors.deepOrange,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: (){
                                                        moveDevice(devices[index]);
                                                        Navigator. of(context). pop();
                                                      },
                                                      child: Text("Save",
                                                        style: TextStyle(
                                                          color:Colors.white,
                                                          fontSize: 20*scaleFactor
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: (){
                                                          setState(() {
                                                            devices[index].id = laboratories[_activeLab-1].id;
                                                          });
                                                          Navigator. of(context). pop();
                                                      },
                                                      child: Text("Close",
                                                      style: TextStyle(
                                                          color:Colors.white,
                                                          fontSize: 20*scaleFactor
                                                        ),),
                                                    ),
                                                  )
                                                ]),
                                              ),
                                            )
                                            ],
                                          ),
                                        ),
                                        
                                        ));
                                    },
                                  );
                              }
                              ),
                              )
                          ],)
                          ),
                        )
                      )
            ]),)
          ),
        ],
      );
      case 2:
        if(_activeCategory != 0)loadAccounts();
        return Column(
        children: [
          SizedBox(height: 15 * scaleFactor,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60 *scaleFactor,
                width: 500.0 * scaleFactor,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20)),
                    color: Color.fromARGB(239, 7, 67, 90)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right_rounded, size: 32.0, color: Colors.white),
                          SizedBox(width: 20.0),
                          Text("Account Management",
                            style: TextStyle(
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
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
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 30.0,bottom: 40),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SizedBox(width: 450 *scaleFactor,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(right: 30.0),
                            itemCount: accountTypes.length,
                            itemBuilder: (context, int index){
                              return 
                                CategoryButton(mainText: accountTypes[index], 
                                  leftText: (index+1).toString(),  
                                  isActive: (_activeCategory == index+1),
                                  onPressed: (){
                                    setActive(index+1);
                                    loadAccounts();
                                  },);
                            }
                            )
                          ),
                      ),
                      SizedBox(width: 0 *scaleFactor,),
                      Padding(padding: const EdgeInsets.only(bottom: 60.0),
                        child: SizedBox(width: 3 * scaleFactor,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:  Color.fromARGB(61, 92, 94, 95),))
                        ),
                      ),
                      SizedBox(width: 30 *scaleFactor,),
                      Expanded(
                        child: Padding(padding: const EdgeInsets.only(right: 30.0,top: 20.0),
                         child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                SizedBox(height: 50.0 *scaleFactor, width: 350.0 * scaleFactor,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Search Account",
                                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))))
                                    ),
                                ),
                                Padding(padding: const EdgeInsets.only(left: 20.0),
                                  child: TextButton(
                                    
                                    onPressed: ()=>{
                                      // if(_activeLab != 0)

                                    },
                                    child: Row(children: [
                                      Icon(Icons.person,
                                        color: (_activeCategory != 0) ? Colors.blue: Colors.grey,
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Text("Add Account", style: TextStyle(color: (_activeCategory != 0) ? Colors.blue: Colors.grey,))
                                    ]),
                                  ),
                                ),
                                  TextButton(
                                    onPressed: ()=>{
                                    },
                                    child: Row(children: [
                                      Icon(Icons.group, color:(_activeCategory != 0) ? Colors.blue: Colors.grey,),
                                      const SizedBox(width: 10.0,),
                                      Text("Group" , style: TextStyle(color :(_activeCategory != 0) ? Colors.blue: Colors.grey,))
                                    ]),
                                  ),
                              ],
                            ),
                            Expanded(child: 
                             (accountTypes.isEmpty && _activeCategory != 0)? const Center(
                                child: Text("No Accounts Available"),
                              ) : 
                              ListView.builder(
                              padding: const EdgeInsets.only(right: 50.0, top: 10.0),
                              itemCount: accounts.length,
                              itemBuilder: (context, int index){
                                return SizedBox(
                                  height: 70 * scaleFactor,
                                  child: AccountButton(account: accounts[index]),
                                );
                              }
                              ),)
                          ],)
                          ),
                        )
                      )
            ]),)
          ),
        ],
      );
      case 3:
        return Column(
        children: [
         SizedBox(height: 15 * scaleFactor,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60 *scaleFactor,
                width: 500.0 * scaleFactor,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20)),
                    color: Colors.blue),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Reports",
                      style: TextStyle(
                        fontSize: 24 * scaleFactor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2 ,
                        color: Colors.white
                      ),)
                    ),
                  ),  
                ),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                   child: SizedBox(
                      width: 150.0 * scaleFactor,
                      height: 150.0 * scaleFactor,
                      child: Image.asset('assets/images/bupolanguiseal.png',
                        isAntiAlias: true,
                      )
                    ),
                 ),
            ],
          )
        ],
      );
      case 4:
        return Column(
        children: [
          SizedBox(height: 15 * scaleFactor,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 60 *scaleFactor,
                width: 500.0 * scaleFactor,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20)),
                    color: Color.fromARGB(239, 7, 67, 90)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right_rounded, size: 32.0, color: Colors.white),
                          SizedBox(width: 20.0),
                          Text("Verification",
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
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 40.0, right: 30.0 * scaleFactor,bottom: 40),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    SizedBox(width: 450 *scaleFactor,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(right: 30.0),
                            itemCount: accountTypes.length-1,
                            itemBuilder: (context, int index){
                              return CategoryButton(mainText: accountTypes[index+1], 
                                  leftText: (index+1).toString(),  
                                  isActive: (_activeCategory == index+1),
                                  onPressed: (){
                                    setActive(index+1);
                                    refresh();
                                  },);
                            }
                            )
                          ),
                      ),
                      SizedBox(width: 0 *scaleFactor,),
                      Padding(padding: const EdgeInsets.only(bottom: 60.0),
                        child: SizedBox(width: 3 * scaleFactor,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color:  Color.fromARGB(61, 92, 94, 95),))
                        ),
                      ),
                      SizedBox(width: 30 *scaleFactor,),
                      Expanded(
                        child: Padding(padding: const EdgeInsets.only(right: 30.0,top: 20.0),
                         child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.transparent),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                Padding(padding: const EdgeInsets.only(left: 20.0),
                                  child: TextButton(
                                    onPressed: ()=>{
                                      if(_activeCategory != 0) deleteAllRequests(_activeCategory)
                                    },
                                    child: const Row(children: [
                                      Icon(Icons.group_remove, color:Colors.red),
                                      SizedBox(width: 10.0,),
                                      Text("Delete All Requests", style: TextStyle(color:Colors.red),)
                                    ]),
                                  ),
                                ),
                                TextButton(
                                    onPressed: ()=>{
                                      if(_activeCategory != 0) refresh()
                                    },
                                    child: const Row(children: [
                                      Icon(Icons.refresh),
                                      SizedBox(width: 10.0,),
                                      Text("Refresh")
                                    ]),
                                  ),
                              ],
                            ),
                            Expanded(child: 
                             (accountTypes.isEmpty && _activeCategory != 0)? const Center(
                                child: Text("No Accounts Available"),
                              ) : 
                              (errorMessage == null) ? StreamBuilder(
                                stream: _streamController.stream,
                                builder: (context, snapshot) {
                                  if(_activeCategory == 0){
                                    return const Center(child: Text(""));
                                  }
                                  if(snapshot.hasData){
                                    if(snapshot.data != "[]"){
                                      var data = json.decode(snapshot.data);
                                      var subjects = [];
                                      data.forEach((String index ,dynamic row) => {
                                         if(row['accountType'] == _activeCategory.toString())subjects.add(Verification(
                                          accountType: row['accountType'],
                                          id : row['id'],
                                          fullname : row['fullname'],
                                          email : row['email'],
                                          contact : row['contact'],
                                          password : row['password'],
                                         ))
                                      });
                                      if(subjects.isNotEmpty) {
                                        return ListView.builder(
                                            padding: const EdgeInsets.only(right: 30.0, top: 10.0),
                                            itemCount: subjects.length,
                                            itemBuilder: (context, int index){
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
                                                        Text(subjects[index].fullname, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                        const Spacer(),
                                                        Container(height: 35*scaleFactor,
                                                          width: 250.0,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration:const BoxDecoration(
                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                              color:Color.fromARGB(255, 255, 216, 202),
                                                            ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Center(
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(Icons.email),
                                                                    const SizedBox(width: 10),
                                                                    Text(
                                                                      subjects[index].email,
                                                                      style: const TextStyle(fontWeight: FontWeight.w400)
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                          ),
                                                          ),
                                                        const SizedBox(width:15),
                                                        SizedBox(width:40,
                                                          child: TextButton(
                                                            onPressed: (){
                                                              reject(subjects[index].id);
                                                            },
                                                            child: const Align(
                                                              alignment: Alignment.center,
                                                              child: Icon(Icons.close, color:Colors.red),))
                                                        ),
                                                        const SizedBox(width:5),
                                                        SizedBox(width:40,
                                                           child: TextButton(
                                                            onPressed: ()=>{
                                                                verify(subjects[index].id)
                                                            },
                                                            child: const Align(
                                                              alignment: Alignment.center,
                                                              child: Icon(Icons.check, color:Colors.green),))
                                                        ),
                                                      ]
                                                    ),
                                                  )
                                                ),
                                              );
                                            }
                                        );
                                      }else{
                                        return const Center(child: Text("There are no verification requests"));
                                      }
                                    }else{
                                      return const Center(child: Text("There are no verification requests"));
                                    }
                                  }else{
                                    return const Center(child: Text(
                                        "There are no verification requests"
                                      ));
                                  }
                                },
                              ) :const Center(child: Text(
                                        "Unable to connect to the server"
                                      )),)
                          ],)
                          ),
                        )
                      )
            ]),)
          ),
        ],
      );
      default:
       return const Text("Error.");
    }
  }
}