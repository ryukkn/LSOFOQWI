class Student{
  String id;
  String fullname;
  String email;
  String? year;
  String? block;
  String contact;
  String status;
  String? schedule;
  String? QR;

  Student({
    required this.id,
    required this.email,
    required this.fullname,
    required this.contact,
    this.year,
    this.block,
    this.schedule,
    this.status = "inactive",
    this.QR,
  });

  Map toJson() => {
        'id': id,
        'email': email,
        'fullname': fullname,
        'year': block,
        'block': block,
        'contact': contact,
        'QR': QR
      };
}