
import 'dart:typed_data';

class Report{
  String id;
  String department;
  String laboratory;
  String faculty;
  String course;
  String yearblock;
  String? timeOut;
  String timeIn;
  String? sessions;
  Uint8List? eSign;

  Report({
    required this.id,
    required this.department,
    required this.laboratory,
    required this.faculty,
    required this.course,
    required this.yearblock,
    this.eSign,
    this.sessions,
    this.timeOut,
    required this.timeIn,
  });
}