import 'dart:convert';

UserResponse userResponseFromJson(String str) => UserResponse.fromJson(json.decode(str));

String userResponseToJson(UserResponse data) => json.encode(data.toJson());

class UserResponse {
  UserData? data;
  String? status;
  String? message;

  UserResponse({this.data, this.status, this.message});

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    data: json["data"] == null ? null : UserData.fromJson(json["data"]),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {"data": data?.toJson(), "status": status, "message": message};
}

class UserData {
  int? empId;
  int? tabUserId;
  int? userType;
  DateTime? lastLogInDateTime;
  String? empName;
  String? empStatus;
  String? userName;
  String? password;
  String? emailId;
  String? hwId;
  String? cityId;
  dynamic mobNo;
  String? jsonstr;

  UserData({
    this.empId,
    this.tabUserId,
    this.userType,
    this.lastLogInDateTime,
    this.empName,
    this.empStatus,
    this.userName,
    this.password,
    this.emailId,
    this.hwId,
    this.cityId,
    this.mobNo,
    this.jsonstr,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    empId: json["empId"],
    tabUserId: json["tabUserId"],
    userType: json["userType"],
    lastLogInDateTime: json["lastLogInDateTime"] == null ? null : DateTime.parse(json["lastLogInDateTime"]),
    empName: json["empName"],
    empStatus: json["empStatus"],
    userName: json["userName"],
    password: json["password"],
    emailId: json["emailId"],
    hwId: json["hwId"],
    cityId: json["cityId"],
    mobNo: json["mobNo"],
    jsonstr: json["jsonstr"],
  );

  Map<String, dynamic> toJson() => {
    "empId": empId,
    "tabUserId": tabUserId,
    "userType": userType,
    "lastLogInDateTime": lastLogInDateTime?.toIso8601String(),
    "empName": empName,
    "empStatus": empStatus,
    "userName": userName,
    "password": password,
    "emailId": emailId,
    "hwId": hwId,
    "cityId": cityId,
    "mobNo": mobNo,
    "jsonstr": jsonstr,
  };
}
