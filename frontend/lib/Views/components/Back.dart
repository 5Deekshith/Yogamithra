import 'package:flutter/material.dart';
import 'package:yoga_mithra/Views/YogaPoseClassifier.dart';
import 'package:yoga_mithra/data/data.dart';
import 'package:yoga_mithra/models/course.dart';

class Back extends StatelessWidget {
  Widget _buildCourses(BuildContext context, int index) {
    Size size = MediaQuery.of(context).size;
    BackPain back = backPainYoga[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YogaPoseClassifier(poseName: back.name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: size.height * 0.2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: Offset(10, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: size.width * 0.3,
                  height: size.height * 0.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(back.imageUrl), // Keep this if needed for UI
                  ),
                ),
                Container(
                  width: size.width * 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          back.name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                        ),
                        SizedBox(height: size.height * 0.01),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(back.desc),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
              itemCount: backPainYoga.length,
              itemBuilder: (context, index) {
                return _buildCourses(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }
}