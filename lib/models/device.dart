import 'package:bupolangui/models/session.dart';

class Device{
  String id;
  String name;
  String labID;
  /*
    Unit Status
    F - Functional
    NF - Not Functional
    M - Missing
    NA - Not Applicable
  */
  String type;
  String systemUnit ;
  String monitor ;
  String mouse;
  String keyboard;
  String avrups;
  String wifidongle;
  String remarks;
  String? QR;
  Session? lastSession;
  bool defective;

  Device({
    required this.id,
    required this.name,
    required this.labID,
    this.lastSession,
    this.type = "PC",
    this.systemUnit = "F",
    this.monitor = "F",
    this.mouse = "F",
    this.keyboard = "F",
    this.avrups = "F",
    this.wifidongle = "N/A",
    this.remarks = "",
    this.QR,
    this.defective = false
  });

  Map toJson() => {
        'id': id,
        'systemUnit': systemUnit,
        'monitor': monitor,
        'mouse': mouse,
        'keyboard': keyboard,
        'avrups': avrups,
        'wifidongle': wifidongle,
        'remarks': remarks,
        'defective': defective,
        'QR': QR
      };
}