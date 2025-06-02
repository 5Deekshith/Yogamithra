import 'package:flutter/material.dart';
import 'package:yoga_mithra/JsonModels/users.dart';
import 'package:yoga_mithra/constants/constants.dart';
import 'package:yoga_mithra/Views/components/style.dart';
import 'package:yoga_mithra/data/data.dart';
import 'package:yoga_mithra/models/pageCall.dart';

class DiffStyles extends StatelessWidget {
  final Users user;
  final String searchQuery;

  const DiffStyles({Key? key, required this.user, required this.searchQuery})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Style> filteredStyles = searchQuery.isEmpty
        ? styles
        : styles
            .where((style) =>
                style.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: appPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'For Practice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: appPadding / 2),
            child: GridView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredStyles.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildStyle(context, filteredStyles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyle(BuildContext context, Style style) {
    Size size = MediaQuery.of(context).size;
    Pagecall pagecall = Pagecall(context: context, user: user);

    return GestureDetector(
      onTap: () {
        // Handle style tap
        pagecall.render(style.pageName);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: appPadding / 2),
            child: Container(
              margin:
                  EdgeInsets.only(top: appPadding, bottom: appPadding * 2),
              width: size.width * 0.4,
              height: size.height * 0.2,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                  topRight: Radius.circular(50.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: black.withOpacity(0.3),
                    blurRadius: 20.0,
                    offset: Offset(5, 15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: appPadding / 2,
                      right: appPadding * 3,
                      top: appPadding,
                    ),
                    child: Text(
                      style.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: appPadding / 2,
                      right: appPadding / 2,
                      bottom: appPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: black.withOpacity(0.3),
                            ),
                            SizedBox(
                              width: size.width * 0.01,
                            ),
                            Text(
                              style.time.toString() + ' min',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: black.withOpacity(0.3),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: white,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              child: Image(
                width: size.width * 0.3,
                height: size.height * 0.2,
                image: AssetImage(style.imageUrl),
              ),
            ),
          )
        ],
      ),
    );
  }
}
