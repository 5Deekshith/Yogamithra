import 'package:flutter/material.dart';
import 'package:yoga_mithra/Views/YogaPoseClassifier.dart';
import 'package:yoga_mithra/constants/constants.dart';
import 'package:yoga_mithra/data/data.dart';
import 'package:yoga_mithra/models/course.dart';

class Shoulders extends StatelessWidget {
  Widget _buildCourses(BuildContext context, int index) {
    Size size = MediaQuery.of(context).size;
    Shoulder shoulders = shoulderYoga[index];

    return GestureDetector(
      onTap:() => {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) =>  YogaPoseClassifier(poseName: shoulders.name,)))
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: appPadding, vertical: appPadding / 2),
        child: Container(
          height: size.height * 0.2,
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                    color: black.withOpacity(0.3),
                    blurRadius: 30.0,
                    offset: Offset(10, 15))
              ]),
          child: Padding(
            padding: const EdgeInsets.all(appPadding),
            child: Row(
              children: [
                Container(
                  width: size.width * 0.3,
                  height: size.height * 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image(
                      image: AssetImage(shoulders.imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  width: size.width * 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: appPadding / 2, top: appPadding / 1.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shoulders.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                       Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(shoulders.desc))),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: shoulderYoga.length,
            itemBuilder: (context, index) {
              return _buildCourses(context, index);
            },
          ))
        ],
      ),
    );
  }
}
