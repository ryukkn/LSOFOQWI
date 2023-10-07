
class Schedule{
  String id;
  String laboratory;
  String labID;
  String course;
  String level;
  String block;
  String blockID;
  String day;
  String time;

  Schedule({
    required this.id,
    required this.course,
    required this.laboratory,
    required this.labID,
    required this.level,
    required this.block,
    required this.blockID,
    required this.day,
    required this.time,
  });
}