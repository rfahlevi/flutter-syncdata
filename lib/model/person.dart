// ignore_for_file: public_member_api_docs, sort_constructors_first
// To parse this JSON data, do
//
//     final person = personFromJson(jsonString);

import 'dart:convert';

Person personFromJson(String str) => Person.fromJson(json.decode(str));

String personToJson(Person data) => json.encode(data.toJson());

class Person {
  int? id;
  String name;
  int age;
  String gender;
  String createdAt;

  Person({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.createdAt,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json["id"],
        name: json["name"],
        age: json["age"],
        gender: json["gender"],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "age": age,
        "gender": gender,
        "created_at": createdAt,
      };
}
