import 'package:flutter/material.dart';
import 'package:yoga_mithra/JsonModels/users.dart';
import 'package:yoga_mithra/Views/back_yoga.dart';
import 'package:yoga_mithra/Views/knee_yoga.dart';
import 'package:yoga_mithra/Views/shoulder_yoga.dart';

class Pagecall {
  final BuildContext context;
  final Users user;

  Pagecall({required this.context, required this.user});

  void render(String page) {
    switch (page) {
      case "shoulder":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ShoulderYoga(user: user)));
        break;
      case "BackPain":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BackYoga(user: user)));
        break;
      case "knee":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => KneeYoga(user: user)));
        break;
    }
  }
}
