// MVVM Signup Module

// lib/app/models/user_model.dart
class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String password;
  final String gender;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.password,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'dateOfBirth': dateOfBirth,
    'password': password,
    'gender': gender,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    dateOfBirth: json['dateOfBirth'] ?? '',
    password: json['password'] ?? '',
    gender: json['gender'] ?? '',
  );
}