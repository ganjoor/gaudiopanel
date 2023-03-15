class PublicRAppUser {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String sureName;
  final int status;
  final String rImageId;

  PublicRAppUser(
      {this.id,
      this.username,
      this.email,
      this.phoneNumber,
      this.firstName,
      this.sureName,
      this.status,
      this.rImageId});

  factory PublicRAppUser.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return PublicRAppUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      sureName: json['sureName'],
      status: json['status'],
      rImageId: json['rImageId'],
    );
  }

  toJson() {
    Map<String, dynamic> m = {};
    m['id'] = id;
    m['username'] = username;
    m['email'] = email;
    m['phoneNumber'] = phoneNumber;
    m['firstName'] = firstName;
    m['sureName'] = sureName;
    m['status'] = status;
    m['rImageId'] = rImageId;
    return m;
  }
}
