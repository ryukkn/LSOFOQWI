import 'student.dart';
import 'device.dart';
class Session{
  String? id;
  String? date;
  Student? student;
  Device? device;

  Session({
    this.id,
    this.date,
    this.student,
    this.device,
  });

  Map toJson() => {
        'id': id,
        'date': date,
        'student': student,
        'device': device,
      };
}