import 'package:bupolangui/models/admin.dart';
import 'package:bupolangui/models/course.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditUser extends StatelessWidget {
  final dynamic account;
  final Function delete;
  final Function save;
  final TextEditingController email;
  final TextEditingController fullname;
  final TextEditingController password;
  final TextEditingController contact;

  
  const EditUser({super.key, required this.account, required this.contact ,required this.delete, required this.save,required this.email,required this.fullname, required this.password});
  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height/1000;
    return AlertDialog(
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Edit Account"),
                      SizedBox(
                          height: 35 * scaleFactor,
                          width:120.0,
                          child: DecoratedBox(
                            decoration:  BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                              color: (account is Admin) ? Colors.grey : Colors.red
                            ),
                            child: FittedBox(
                              fit : BoxFit.contain,
                              child: TextButton(onPressed: () async{
                                  if(account is! Admin){
                                      await showDialog(context: context, 
                                      builder: (context) => AlertDialog(
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                        title: const Text("Are you sure you want to delete this account?") ,
                                        actions:[
                                          TextButton(onPressed: (){
                                            delete();
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
                                    }
                              }, 
                                child: const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text("Delete Account", style: TextStyle(color: Colors.white),),
                                )
                              ),
                            ),
                          ),
                        ),  
                  ],
                ),
                content: SizedBox(
                  width: 500,
                  height: 400.0,
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
                                  controller: fullname,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Fullname",
                                    
                                  ),
                                ),
                                SizedBox(height: 20.0 *scaleFactor,),
                                TextFormField(
                                  controller: email,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Email",
                                  ),
                                ),
                                SizedBox(height: 20.0 *scaleFactor,),
                                TextFormField(
                                  controller: contact,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Contact",
                                  ),
                                ),
                                SizedBox(height: 20.0 *scaleFactor,),
                                TextFormField(
                                  controller: password,
                                  decoration: const InputDecoration(
                                    hintText: "Password",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Change Password",
                                  ),
                                ),
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
                                    save();
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
              );
                                    
  }
}

class EditProfile extends StatelessWidget {
  final dynamic account;
  final Function save;
  final TextEditingController fullname;
  final TextEditingController password;
  final TextEditingController contact;

  
  const EditProfile({super.key, required this.account, required this.contact, required this.save,required this.fullname, required this.password});
  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.height/1000;
    return AlertDialog(
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Edit Account"),
                  ]
                ),
                content: SizedBox(
                  width: 500,
                  height: 350.0,
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
                                  controller: fullname,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Fullname",
                                    
                                  ),
                                ),
                                SizedBox(height: 20.0 *scaleFactor,),
                                TextFormField(
                                  controller: contact,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Contact",
                                  ),
                                ),
                                SizedBox(height: 20.0 *scaleFactor,),
                                TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: "Password",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                    ),
                                    labelText: "Change Password",
                                  ),
                                ),
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
                                    save();
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
              );
                                    
  }
}

int getNumOfBlocks(List<Course> courses,String courseID,String year){
  int numOfBlocks = 0;
  for (var course in courses) {
    if( year == course.year && course.courseID == courseID){
      numOfBlocks+=1;
    }
   }
  return numOfBlocks;
}

// ignore: must_be_immutable
manageCourse (double scaleFactor, List<Course>? courses, Course? course, List<TextEditingController> courseController, onSubmit, onDelete) => StatefulBuilder(
      builder: (context,setState) {
        if(courses!=null){
          courseController[0].text = course!.course;
          courseController[1].text = getNumOfBlocks(courses, course.courseID!, "First Year").toString();
          courseController[2].text = getNumOfBlocks(courses, course.courseID!, "Second Year").toString();
          courseController[3].text = getNumOfBlocks(courses, course.courseID!, "Third Year").toString();
          courseController[4].text = getNumOfBlocks(courses, course.courseID!, "Fourth Year").toString();
          courseController[5].text = getNumOfBlocks(courses, course.courseID!, "Fifth Year").toString();
        }else{
          courseController[0].text = "";
           courseController[1].text = "";
            courseController[2].text = "";
             courseController[3].text = "";
              courseController[4].text = "";
               courseController[5].text = "";
        }
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: SizedBox(
          width: 500*scaleFactor,
          height: 700*scaleFactor,
          child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: double.infinity,
                      height: 60.0,
                      child: DecoratedBox(decoration: const BoxDecoration(color: Colors.blue),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 100,),
                            const Spacer(),
                            Align(
                              alignment:Alignment.center,
                              child: Text((courses != null)? "Course Information" :"Add Course" ,style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                            ),
                            const Spacer(),
                            (courses==null)?  const SizedBox(width: 100,):SizedBox(width: 100,height: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 15.0),
                                child: DecoratedBox(decoration: const BoxDecoration(color: Colors.red, 
                                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                                ),
                                  child: TextButton(
                                    onPressed:()async{
                                      await showDialog(context: context, builder: (context)=>AlertDialog(
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                        title: const Text("Are you sure you want to delete course?"),
                                        actions: [
                                          TextButton(onPressed: (){
                                            onDelete();
                                            Navigator.of(context).pop();
                                          }, child: const Text("Yes")),
                                          TextButton(onPressed: (){
                                            Navigator.of(context).pop();
                                          }, child: const Text("No")),
                                        ],));
                                        Navigator.of(context).pop();
                                    },
                                    child: const Center(child: Text("Delete", style:TextStyle(color:Colors.white)))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                     SizedBox(height: 10.0 *scaleFactor,),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextFormField(
                          readOnly: (courses!=null),
                          controller: courseController[0],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            labelText: "Course",
                          ),
                        ),
                      ),
                    SizedBox(height: 10.0 *scaleFactor,),
                     SizedBox(
                        width: double.infinity,
                        height: 15*scaleFactor,
                        child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                      ),
                      SizedBox(
                      width: double.infinity,
                      height: 60*scaleFactor,
                      child: DecoratedBox(decoration: const BoxDecoration(color: Color.fromARGB(255, 200, 238, 255)),
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                            TextSpan(text: "BLOCKS PER LEVEL\n", style: TextStyle(height: 1.8,fontWeight: FontWeight.bold,letterSpacing: 1.1, fontSize: 20*scaleFactor, color: Colors.black)),
                            TextSpan(text: "Specified number of blocks per level.\n", style: TextStyle(height: 1.5,letterSpacing: 1.0, fontSize: 14*scaleFactor, color: Colors.black)),
                          ])),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: double.infinity,
                        height: 15*scaleFactor,
                        child: const DecoratedBox(decoration: BoxDecoration(color: Colors.lightBlueAccent)),
                      ),
                    
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 160.0,
                                    child: TextFormField(
                                    readOnly: true,
                                    textAlign: TextAlign.center,
                                    initialValue: "First Year",
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
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 140.0,
                                    child: TextFormField(
                                      readOnly: (courses!=null),
                                    textAlign: TextAlign.center,
                                    controller: courseController[1],
                                    decoration: const InputDecoration(
                                      hintText: "No. of blocks",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          ),
                                        ),
                                    ),
                                  ),
                              ],),
                            ),

                            Padding(
                            padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 160.0,
                                    child: TextFormField(
                                    readOnly: true,
                                    textAlign: TextAlign.center,
                                    initialValue: "Second Year",
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
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 140.0,
                                    child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: courseController[2],
                                readOnly: (courses!=null),
                                    decoration: const InputDecoration(
                                       hintText: "No. of blocks",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                                          ),
                                        ),
                                    ),
                                  ),
                              ],),
                            ),
                            Padding(
                            padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 160.0,
                                    child: TextFormField(
                                    readOnly: true,
                                    textAlign: TextAlign.center,
                                    initialValue: "Third Year",
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
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 140.0,
                                    child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: courseController[3],
                                    readOnly: (courses!=null),
                                    decoration: const InputDecoration(
                                       hintText: "No. of blocks",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                                          ),
                                        ),
                                    ),
                                  ),
                              ],),
                            ),
                            Padding(
                            padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 160.0,
                                    child: TextFormField(
                                    readOnly: true,
                                    textAlign: TextAlign.center,
                                    initialValue: "Fourth Year",
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
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 140.0,
                                    child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: courseController[4],
                                readOnly: (courses!=null),
                                    decoration: const InputDecoration(
                                       hintText: "No. of blocks",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                                          ),
                                        ),
                                    ),
                                  ),
                              ],),
                            ),
                            Padding(
                            padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 160.0,
                                    child: TextFormField(
                                    readOnly: true,
                                    textAlign: TextAlign.center,
                                    initialValue: "Fifth Year",
                                    
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
                                  SizedBox(
                                    height: 50.0 *scaleFactor,
                                    width: 140.0,
                                    child: TextFormField(
                                    textAlign: TextAlign.center,
                            controller: courseController[5],
                            readOnly: (courses!=null),
                                    decoration: const InputDecoration(
                                       hintText: "No. of blocks",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                                          ),
                                        ),
                                    ),
                                  ),
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
                  (courses!=null)? const SizedBox():Expanded(child: TextButton(child: Text((courses != null) ? "SAVE" : "ADD", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: (){
                    onSubmit();
                    Navigator.of(context).pop();
                  },)),
                   Expanded(child: TextButton(child: const Text("CANCEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),onPressed: ()=>{
                    Navigator.of(context).pop()},)),
                ],)
                )
              )
            ],
          ),
        ),
      );
      }
      );


popUpMessage(context, title)=>showDialog(context: context, builder: (context) => 
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
                                child: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2)),onPressed:(){
                                  Navigator.of(context).pop();
                                }),
                            ),
                            ]
                       ));

  showError(context, title)=>showDialog(context: context, builder: (context) => 
  SimpleDialog(
    alignment: Alignment.bottomCenter,
    backgroundColor: Colors.transparent,
    children:[
        SizedBox(
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)))
          ),
          child: FittedBox(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18.0,letterSpacing: 1.2))),onPressed:(){
              Navigator.of(context).pop();
          }),
      ),
      ]
  ));