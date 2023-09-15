class Admin{
  String id;
  String fullname;
  String email;
  String contact;
  String status;
  String? QR;

  Admin({
    required this.id,
    required this.email,
    required this.fullname,
    required this.contact,
    this.status = "inactive",
  });

  Map toJson() => {
        'id': id,
        'email': email,
        'fullname': fullname,
        'contact': contact,
        'QR': QR
      };
}