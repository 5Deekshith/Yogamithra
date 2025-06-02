import 'package:flutter/material.dart';
import 'package:yoga_mithra/JsonModels/users.dart';
import 'package:yoga_mithra/Views/components/Back.dart';
import 'package:yoga_mithra/constants/constants.dart';

class BackYoga extends StatefulWidget {
  final Users user;
  const BackYoga({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<BackYoga> {
  int selsctedIconIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: appPadding * 2),
        child: Column(
          children: [
            AppBar(
              backgroundColor: white,
              title: const Text(
                "Back Pain",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            Back(),
          ],
        ),
      ),
    );
  }
}
