import 'package:bupolangui/models/admin.dart';
import 'package:bupolangui/models/student.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditUser extends StatelessWidget {
  final dynamic account;
  final Function delete;
  final Function save;
  final TextEditingController email;
  final TextEditingController fullname;
  
  const EditUser({super.key, required this.account, required this.delete, required this.save,required this.email,required this.fullname});
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