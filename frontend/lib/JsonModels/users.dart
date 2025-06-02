//In here first we create the users json model
// To parse this JSON data, do
//

class Users {
  final int? usrId;
  final String usrName;
  final String email;
  final int mobileNumber;
  final String usrPassword;

  Users(
      {this.usrId,
      required this.usrName,
      required this.usrPassword,
      required this.email,
      required this.mobileNumber});

  factory Users.fromMap(Map<String, dynamic> json) => Users(
      usrId: json["usrId"],
      usrName: json["usrName"],
      usrPassword: json["usrPassword"],
      email: json['email'],
      mobileNumber: json['mobileNumber']);

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "usrName": usrName,
        "usrPassword": usrPassword,
        "email": email,
        "mobileNumber": mobileNumber
      };

  // Getters
  int? get id => usrId;
  String get name => usrName;
  String get userEmail => email;
  int get phone => mobileNumber;
  String get password => usrPassword;
}
