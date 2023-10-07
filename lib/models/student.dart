class Student{
  String id;
  String fullname;
  String email;
  String? block;
  String contact;
  String status;
  String? schedule;
  String? QR;
  String? profile;

  Student({
    required this.id,
    required this.email,
    required this.fullname,
    required this.contact,
    this.profile,
    this.block,
    this.schedule,
    this.status = "inactive",
    this.QR,
  });

  Map toJson() => {
        'id': id,
        'email': email,
        'fullname': fullname,
        'block': block,
        'contact': contact,
        'profile': profile,
        'QR': QR
      };
}