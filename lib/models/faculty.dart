class Faculty{
  String id;
  String fullname;
  String email;
  String? department;
  String contact;
  String? status;
  String? schedule;

  Faculty({
    required this.id,
    required this.email,
    required this.fullname,
    required this.contact,
    this.department,
    this.schedule,
    this.status = "inactive",
  });

  Map toJson() => {
        'id': id,
        'email': email,
        'fullname': fullname,
        'department': department,
        'contact': contact,
        'schedule': schedule,
      };
}