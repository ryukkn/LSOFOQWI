import 'package:flutter/material.dart';

class EvaluationSelector extends StatefulWidget {
  final String title;
  final TextEditingController defaultValue;
  final bool isrequired;
  final IconData icon;
  final Function? callback;
  List<String> options = ["F", "NF", "M", "N/A"];
  EvaluationSelector({super.key, required this.icon, this.callback,required this.defaultValue,required this.title, this.isrequired = true});

  @override
  State<EvaluationSelector> createState() => _EvaluationSelectorState();
}

class _EvaluationSelectorState extends State<EvaluationSelector> {
  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.height/900;
    return SizedBox(
                width: double.infinity,
                height: 160.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration:  BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                      boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 1), // changes position of shadow
                              )
                            ]
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50.0 *scaleFactor,
                          child: DecoratedBox(decoration: BoxDecoration(color: (widget.defaultValue.text == "") ? Colors.black87 : Colors.lightBlue,
                          ),
                            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Align(alignment: Alignment.centerLeft,
                                child: Row(children: [
                                  Icon(widget.icon, color: Colors.white,),
                                  SizedBox(
                                    width: 15*scaleFactor,
                                  ),
                                  Text(widget.title, style: TextStyle(letterSpacing: 1.4,fontWeight: FontWeight.bold, color: Colors.white , fontSize: 18*scaleFactor),),
                                  const Spacer(),
                                  Text("*", style: TextStyle(letterSpacing: 1.2,fontWeight: FontWeight.bold, color: Colors.red, fontSize: 20*scaleFactor),),
                                  
                                ]),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.symmetric( horizontal: 10.0 ,vertical: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Row(
                                  children: [
                                     Radio(
                                    value: widget.options[0],
                                    groupValue: widget.defaultValue.text,
                                    onChanged: (value){
                                      
                                      setState((){
                                        widget.defaultValue.text = value.toString();
                                      });
                                      widget.callback!();
                                    },
                                  ),
                      
                                    Text("Functional", style: TextStyle(fontSize: 16*scaleFactor,fontWeight: FontWeight.w600, 
                                    color: (widget.defaultValue.text==widget.options[0]) ? Colors.blue: Colors.black)),
                                 
                                  ],
                                ),
                                 Row(
                                  children: [
                                     Radio(
                                    value: widget.options[1],
                                    groupValue: widget.defaultValue.text,
                                    onChanged: (value){
                                      setState((){
                                        widget.defaultValue.text = value.toString();
                                      });
                                      widget.callback!();
                                    },
                                  ),
                         
                                    Text("Not Functional", style: TextStyle(fontSize: 16*scaleFactor,fontWeight: FontWeight.w600, color: (widget.defaultValue.text==widget.options[1]) ? Colors.blue: Colors.black)),
                                 
                                  ],
                                )
                              ],),
                              Column(
                                mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Row(
                                  children: [
                                     Radio(
                                    value: widget.options[2],
                                    groupValue: widget.defaultValue.text,
                                    onChanged: (value){
                                      setState((){
                                        widget.defaultValue.text = value.toString();
                                      });
                                      widget.callback!();
                                    },
                                  ),
                  
                                    Text("Missing", style: TextStyle(fontSize: 16*scaleFactor,fontWeight: FontWeight.w600, color: (widget.defaultValue.text==widget.options[2]) ? Colors.blue: Colors.black)),
                                 
                                  ],
                                ),
                                 Row(
                                  children: [
                                     Radio(
                                    value: widget.options[3],
                                    groupValue: widget.defaultValue.text,
                                    onChanged: (value){
                                      setState((){
                                        widget.defaultValue.text = value.toString();
                                      });
                                      widget.callback!();
                                    },
                                  ),
                       
                                    Text("Not Applicable", style: TextStyle(fontSize: 16*scaleFactor,fontWeight: FontWeight.w600, color: (widget.defaultValue.text==widget.options[3]) ? Colors.blue: Colors.black)),
                                 
                                  ],
                                )
                              ],),
                          ],),
                        ))
                      ],
                    ),
                  ),
                ) ,);
  }
}