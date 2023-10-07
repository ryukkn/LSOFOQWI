class Faculty{
  String id;
  String fullname;
  String email;
  String? department;
  String contact;
  String? status;
  String? profile;

  Faculty({
    required this.id,
    required this.email,
    required this.fullname,
    required this.contact,
    this.profile,
    this.department,
    this.status = "inactive",
  });

  Map toJson() => {
        'id': id,
        'email': email,
        'fullname': fullname,
        'department': department,
        'profile': profile,
        'contact': contact,
      };
}


