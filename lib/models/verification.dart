class Verification{
  String accountType;
  String id;
  String fullname;
  String email;
  String password;
  String contact;

  Verification({
    required this.accountType,
    required this.id,
    required this.fullname, 
    required this.email,
    required this.password,
    required this.contact
    });

  Map toJson() => {
        'accountType': accountType,
        'id': id,
        'fullname': fullname,
        'email': email,
        'password': password,
        'contact': contact,
      };
}