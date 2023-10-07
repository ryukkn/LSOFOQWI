class Session{
  String id;
  String timestamp;
  String student;
  String device;
  String? studentQR;
  String? deviceQR;
  String? systemUnit;
  String? monitor;
  String? keyboard;
  String? mouse;
  String? avrups;
  String? wifidongle;
  String? remarks;

  Session({
    required this.id,
    required this.timestamp,
    required this.student,
    required this.device,
    this.studentQR,
    this.deviceQR,
    this.systemUnit,
    this.monitor,
    this.keyboard,
    this.mouse,
    this.avrups,
    this.wifidongle,
    this.remarks,
  });

}