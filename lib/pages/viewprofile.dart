import 'dart:convert';
import 'dart:io';

import 'package:bupolangui/components/popups.dart';
import 'package:bupolangui/components/preloader.dart';
import 'package:bupolangui/functions/functions.dart';
import 'package:bupolangui/models/course.dart';
import 'package:bupolangui/models/faculty.dart';
import 'package:bupolangui/models/student.dart';
import 'package:bupolangui/server/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as server;
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ViewProfile extends StatefulWidget {
  dynamic account;
  ViewProfile({super.key, required this.account});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {

   List<Course> availableCourses = [];

   XFile? fileImage;

  Widget? profilePic;

  String? studentCourse;

  bool hasLoaded = false;
  


  Map<String, String> _courses ={};
  Map<String, String> _levels = {};
  Map<String, String> _blocks = {};

  String? course;
  String? level;
  String? block;

  TextEditingController levelController = TextEditingController();
  TextEditingController blockController = TextEditingController();

  TextEditingController fullnameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
   Future loadOptions() async{
      Map<String, String> courses ={};
      Map<String, String> levels = {};
      Map<String, String> blocks = {};
      for (var _course in availableCourses) {
        if(!courses.containsKey(_course.course)){
            courses[_course.course] = _course.courseID!;
        }

        if(!levels.containsKey(_course.year) && (_course.courseID == course)){ 
            levels[_course.year] = _course.levelID!;
        }

        if(!blocks.containsKey(_course.block) &&  (_course.levelID == level) ){
            blocks[_course.block] = _course.id;
        }
      }

        if(mounted){
          setState(() {
            _courses = courses;
            _levels = levels;
            _blocks = blocks;
          });
        }
  } 
  

  Future getAvailableCourses() async {
    var url = Uri.parse("${Connection.host}flutter_php/availablecourses.php");
    var response = await server.post(url, body: {
    });
    var data = json.decode(response.body);
    if(data["success"]){
        List<Course> courses = [];
        data['rows'].forEach((row){
            courses.add(
              Course(id: row['ID'],courseID: row['courseID'], levelID: row['levelID'] ,  course: row['course'], year: row['level'], block: row['block'])
            );
    });
     if(mounted){
       setState(() {
          availableCourses = courses;
        });
     }
    }
  }

  Future updateBlock()async{
    setState(() {
      hasLoaded = false;
    });
      var url = Uri.parse("${Connection.host}flutter_php/student_updateblock.php");

      var response = await server.post(
              url, 
              body: {
                  'id' : widget.account.id,
                  'blockID' : block,
              }
      );

      var data = json.decode(response.body);
      if(!data['success']){
        print("Error.");
      }else{
        var student = await getStudent(widget.account.QR);
        for (var element in availableCourses) { 
                if(element.id == student!.block){
                  var yearlevel = "";
                  switch(element.year){
                        case "First Year":
                        yearlevel = "1";
                        break;
                      case "Second Year":
                        yearlevel = "2";
                        break;
                      case "Third Year":
                        yearlevel = "3";
                        break;
                      case "Fourth Year":
                        yearlevel = "4";
                        break;
                      case "Fifth Year":
                        yearlevel = "5";
                        break;
                    }
                  setState((){
                     studentCourse = "${parseAcronym(element.course)} $yearlevel-${element.block.replaceAll("Block ", "")}";
                    widget.account = student;
                    hasLoaded = true;
                  });
                  continue;
                }
              }
      
      }
  }

  Future pickProfile(ImageSource source) async{

    final image = await ImagePicker()
          .pickImage(source: source, maxWidth: 300, maxHeight: 300);
    if(image == null) return;

    setState(() {
      fileImage = image;
      hasLoaded = false;
    });

    var url = Uri.parse("${Connection.host}flutter_php/uploadimage.php");

      List<int> imageBytes = File(fileImage!.path).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      //convert file image to Base64 encoding
      var response = await server.post(
              url, 
              body: {
                  'id' : widget.account.id,
                  'account' : (widget.account is Faculty) ? "Faculty" : "Student",
                 'image': baseimage,
              }
      );
      var data = json.decode(response.body);
      if(!data['success']){
        print("Error");
      }else{
        setState(() {
          widget.account.profile = data['profile'];
        });
        var url = Uri.parse('${Connection.host}flutter_php/' + widget.account.profile).toString();
         Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
            .buffer
            .asUint8List();
        if(mounted){
          setState(() {
            profilePic = Image.memory(bytes, fit: BoxFit.cover,);
            hasLoaded = true;
        });
        }
      }

  }

 @override
  void initState() {
    super.initState();
    if(widget.account is Student){
        getAvailableCourses().then((value){
            if(mounted){
              getUpdatedProfile().then((x){
                if(mounted){
                  setState(() {
                    hasLoaded = true;
                  });
                }
              });
            }
        }); 
    }else{
     if(mounted){
        getUpdatedProfile().then((x){
          setState(() {
            hasLoaded = true;
          });
        });
      }
    }
  }
  Future getUpdatedProfile() async{
    String type = "";
    if(widget.account is Faculty){
      type = "faculty";
    }else{
      type = "student";
    }
    var url = Uri.parse("${Connection.host}flutter_php/getupdatedprofile.php");
    var response = await server.post(url, body: {
      "id": widget.account.id,
      "type": type
    });

    var data = json.decode(response.body);

    if(!data['success']){
      print(data['message']);
      return;
    }
     if(widget.account is Student){
      var student = decodeStudent(data['row']);
       for (var element in availableCourses) { 
        if(element.id == student.block){
          var yearlevel = "";
          switch(element.year){
                case "First Year":
                yearlevel = "1";
                break;
              case "Second Year":
                yearlevel = "2";
                break;
              case "Third Year":
                yearlevel = "3";
                break;
              case "Fourth Year":
                yearlevel = "4";
                break;
              case "Fifth Year":
                yearlevel = "5";
                break;
            }
            
          setState((){
            studentCourse = "${parseAcronym(element.course)} $yearlevel-${element.block.replaceAll("Block ", "")}";
            widget.account = student;
          });

        }
      }
     }
     setState(() {
       if(widget.account is Faculty){
        widget.account = decodeFaculty(data['row']);
       }else{
        widget.account = decodeStudent(data['row']);
       }
     });
      if(widget.account.profile != null){
        try{
            var url = Uri.parse('${Connection.host}flutter_php/' + widget.account.profile!).toString();
          Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
              .buffer
              .asUint8List();
          if(mounted){
            setState(() {
              profilePic = Image.memory(bytes, fit: BoxFit.cover,);
            });
          }
        }catch(e){
          profilePic == null;
        }
      }
                 
  }

  @override
  void dispose(){
    super.dispose();
    levelController.dispose();
    blockController.dispose();
    fullnameController.dispose();
    contactController.dispose();
    passwordController.dispose();
  }

  bool updatingProfile = false;
  Future updateProfile() async{
    var url = Uri.parse("${Connection.host}flutter_php/editaccount.php");
    var response = await server.post(url, body: {
      "id": widget.account.id,
      "type": (widget.account is Faculty)? "faculty" : "student",
      "fullname": fullnameController.text,
      "contact" : contactController.text,
      "password": passwordController.text,
    });
    var data = json.decode(response.body);
    if(!data['success']){
      print(data['message']);
    }
  }


  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height/1000;
    return WillPopScope(
      onWillPop: ()async{
        Navigator.of(context).pop(widget.account);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text("YOUR PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,letterSpacing: 1.5, fontSize: 20 * scaleFactor),),
        ),
        body: (!hasLoaded) ? Center(child:loader(scaleFactor)) : Column(children: [
            SizedBox(
            width: double.infinity,
            height: 320*scaleFactor,
            child: DecoratedBox(decoration: const  BoxDecoration(
              color: Colors.lightBlueAccent ,
              borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(60.0,30.0), bottomRight: Radius.elliptical(60.0,30.0) )  
            ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 280*scaleFactor,
                      height: 280*scaleFactor,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(blurRadius: 1.5,spreadRadius: 1.5,offset: Offset(0,2),
                              color: Colors.black38,
                            )
                          ],
                          color: Color.fromARGB(255, 188, 230, 230),
                      ),
                      ),
                    Container(
                      width: 260*scaleFactor,
                      height: 260*scaleFactor,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(shape: BoxShape.circle,
                          color: Colors.white,
                      ),
                      ),
                    SizedBox(
                      width: 240*scaleFactor,
                      height: 240*scaleFactor,
                      child: Stack(
                        children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: (profilePic != null)?
                             profilePic
                                :Text(parseAcronym(widget.account.fullname)),),
                          Align(alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 0.0),
                              child: MenuAnchor(
                                builder:(BuildContext context, MenuController controller,Widget? child){
                                  return InkWell(
                                    onTap: (){
                                       if (controller.isOpen) {
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                    },
                                    child: Icon(Icons.add_a_photo, size: 50*scaleFactor, color: Colors.white,
                                      shadows: const [
                                        Shadow(offset: Offset(0, 2),color: Colors.black26,blurRadius: 1.5)
                                      ],
                                    ));
                                },
                                menuChildren: List<MenuItemButton>.generate(2, (index) => MenuItemButton(
                                  child: Text((index==0)? "Use Camera" : "Browse Gallery"),
                                  onPressed: () {
                                  if(index == 0){
                                    pickProfile(ImageSource.camera);
                                  }else{
                                    pickProfile(ImageSource.gallery);
                                  }
                                },)),
                              )),
                          )
                        ],
                      )),
                  ],
                )
              ),
            ),
          ),
            const SizedBox(height: 15 ,),
            SizedBox(height: 40,width: double.infinity,
              child: Center(child: Text(widget.account.fullname.toString().toUpperCase(), 
              style:TextStyle(fontWeight: FontWeight.bold,fontSize: 28*scaleFactor,letterSpacing: 1.5) ,),),
            ),
             SizedBox(height: 40,width: double.infinity,
              child: Center(child: DecoratedBox(
                decoration: const BoxDecoration(color:Colors.blue, borderRadius: BorderRadius.all(Radius.circular(15.0))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 5.0),
                  child: Text((widget.account is Faculty) ? "FACULTY": "STUDENT", 
                  style:TextStyle(color:Colors.white, fontWeight: FontWeight.bold,fontSize: 24*scaleFactor,letterSpacing: 1.2) ,),
                ),
              ),),
            ),
                 const SizedBox(height: 10 ,),
             const SizedBox(
              width: double.infinity,
              height: 10,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
            ),
              SizedBox(height: 60,width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(color: const Color.fromARGB(255, 225, 241, 255)),
                child: Center(child: Text((widget.account is Faculty) ? (widget.account.department != null) ? widget.account.department.toString().toUpperCase() :"NOT SET": (studentCourse!=null) ? studentCourse!  :"NOT SET", 
                style:TextStyle(color:Colors.black87,fontSize: 22*scaleFactor,letterSpacing: 1.9, fontWeight: FontWeight.bold),),),
              ),
            ),
              const SizedBox(
              width: double.infinity,
              height: 10,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
            ),
              SizedBox(height: 40,width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Color.fromARGB(255, 240, 250, 255)),
                child: Center(child: Text("Contact No. : ${widget.account.contact}", 
                style:TextStyle(fontSize: 20*scaleFactor,letterSpacing: 1.0) ,),),
              ),
            ),
             const SizedBox(
              width: double.infinity,
              height: 10,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
            ),
             const SizedBox(height: 20 ,),
            SizedBox(height: 40,width: 200,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))),
                  onPressed: () async{
                    fullnameController.text = widget.account.fullname;
                    contactController.text = widget.account.contact;
                    passwordController.text = "";
                    var hasUpdate =  await showDialog(context: context, builder: (context) => EditProfile(account: widget.account, save: (){
                      final bool isValidNumber = RegExp("^09[0-9]{9}\$")
                                        .hasMatch(contactController.text);
                      if(!isValidNumber){
                        showError(context, "Enter a valid 11-digit number (PH)");
                        return;
                      }

                      if(passwordController.text !="" && passwordController.text.trim().length < 8){
                        showError(context, "Password must be at least 8 characters long");
                        print("error");
                        return;
                      }
                       Navigator.of(context).pop("has_update");
                      
                    }, fullname: fullnameController, password: passwordController, contact: contactController));
                    if(hasUpdate!=null){
                      setState(() {
                        hasLoaded = false;
                      });
                      await updateProfile();
                      await getUpdatedProfile(); 
                      setState(() {
                        hasLoaded = true;
                      });
                    }
                  },
                  child: Text("Edit Profile", 
                  style:TextStyle(color: (updatingProfile)? Colors.grey : Colors.white,fontSize: 16*scaleFactor,letterSpacing: 1.0, fontWeight: FontWeight.bold) ,),
                ),),
          const SizedBox(height: 20 ,),
             (widget.account is Faculty) ? const SizedBox():SizedBox(height: 40,width: 200,
              child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))),
                  onPressed: (){
                    loadOptions();
                     showDialog(context: context, builder: (context) => StatefulBuilder(
                                    builder: (context,setState) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        clipBehavior: Clip.antiAlias,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                        content: SizedBox(
                                          width: 500*scaleFactor,
                                          height: 460*scaleFactor,
                                          child: Column(
                                                  children: [
                                                    const SizedBox(width: double.infinity,
                                                      height: 60.0,
                                                      child: DecoratedBox(decoration: BoxDecoration(color: Colors.blue),
                                                        child: Align(
                                                          alignment:Alignment.center,
                                                          child: Text("Select course",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(15.0),
                                                        child: Column(children: [
                                                          Padding(
                              padding: const EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                        DropdownMenu(
                                                          enabled: (_courses.isNotEmpty),
                                                          initialSelection: (course != null) ? course: null,
                                                          hintText: "Choose Course",
                                                          textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                            width: 250*scaleFactor,
                                                            onSelected: (String? value){
                                                            levelController.text = "";
                                                            blockController.text = "";
                                                              setState((){
                                                                course = value;
                                                                level = null;
                                                                block = null;
                                                                _blocks = {};
                                                              });
                                                            loadOptions();
                                                            },
                                                            dropdownMenuEntries: _courses.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                              return DropdownMenuEntry<String>(value: _courses[item]!, label: item);
                                                            }).toList(),
                                                          )
                                                      ],),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                      
                                                        DropdownMenu(
                                                        initialSelection: (level != null) ? level: null,
                                                        controller:levelController,
                                                        hintText: "Choose Year Level",
                                                        enabled: (_levels.isNotEmpty),
                                                          textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                            width: 250*scaleFactor,
                                                            onSelected: (String? value){
                                                              blockController.text ="";
                                                              setState((){
                                                                level = value;
                                                                block = null;
                                                              });
                                                              loadOptions();
                                                            },
                                                            dropdownMenuEntries: _levels.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                              return DropdownMenuEntry<String>(value: _levels[item]!, label: item);
                                                            }).toList(),
                                                          )
                                                      ],),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                       
                                                        DropdownMenu(
                                                          controller:blockController,
                                                          hintText: "Choose Block",
                                                          enabled: (_blocks.isNotEmpty),
                                                            width: 250*scaleFactor,
                                                            textStyle: TextStyle(fontSize: 16*scaleFactor),
                                                            onSelected: (String? value)=>{
                                                              setState((){
                                                                block = value;
                                                                print(block);
                                                              })
                                                            },
                                                            dropdownMenuEntries: _blocks.keys.toList().map<DropdownMenuEntry<String>>((String item) {
                                                              return DropdownMenuEntry<String>(value: _blocks[item]!, label: item);
                                                            }).toList(),
                                                          )
                                                      ],),
                                                    ),
                                                  ],)
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.infinity ,
                                                height: 60*scaleFactor,
                                                child: DecoratedBox(decoration: const BoxDecoration(color: Colors.orange),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                  Expanded(child: TextButton(child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),onPressed: ()=>{
                                                    Navigator.of(context).pop()},)),
                                                  Expanded(child: TextButton(child: Text("Update", style: TextStyle(color: (block == null) ? Colors.grey:Colors.white, fontWeight: FontWeight.bold)),
                                                  onPressed: (){
                                                    if(block!=null){
                                                      updateBlock();
                                                      Navigator.of(context).pop();
                                                    }
                                                  },))
                                                ],)
                                                )
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  ));
                  },
                  child: Text("Update Block", 
                  style:TextStyle(fontSize: 16*scaleFactor,letterSpacing: 1.0, fontWeight: FontWeight.bold) ,),
                ),),
        ],),
      ),
    );
  }
}