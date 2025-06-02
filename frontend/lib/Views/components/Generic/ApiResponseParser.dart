// To parse this JSON data, do
//
//     final responseParser = responseParserFromJson(jsonString);

import 'dart:convert';

ResponseParser responseParserFromJson(String str) =>
    ResponseParser.fromJson(json.decode(str));

String responseParserToJson(ResponseParser data) => json.encode(data.toJson());

class ResponseParser {
  List<String> feedback;
  int matchPercentage;

  ResponseParser({
    required this.feedback,
    required this.matchPercentage,
  });

  factory ResponseParser.fromJson(Map<String, dynamic> json) => ResponseParser(
        feedback: List<String>.from(json["feedback"].map((x) => x)),
        matchPercentage: json["match_percentage"],
      );

  Map<String, dynamic> toJson() => {
        "feedback": List<dynamic>.from(feedback.map((x) => x)),
        "match_percentage": matchPercentage,
      };
}
