import 'package:bupolangui/models/student.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:qr_flutter/qr_flutter.dart';


class StudentView extends StatefulWidget {
  const StudentView({super.key, required this.title, required this.student});
  final String title;
  final Student student;

  @override
  State<StudentView> createState() => _StudentView();
}

class _StudentView extends State<StudentView> {
  
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // double scaleFactor = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:Center(
        child: QrImageView(
          data: widget.student.QR!,
          version: QrVersions.auto,
          size: 400.0,
          ),
      )
    );
  }

}