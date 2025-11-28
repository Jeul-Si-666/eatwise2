import 'dart:convert';
import 'package:http/http.dart';

import 'package:eatwise2/util/config.dart';

class ReportHasil {
  final String  imageUrl, title, nutritionInfo;
  final int currentCalories, totalCalories;
  final bool isGood;
  final List<String> composition;
  
  ReportHasil({
    required this.isGood,
    required this.imageUrl,
    required this.title,
    required this.composition,
    required this.nutritionInfo,
    required this.currentCalories,
    required this.totalCalories,

  });

  factory ReportHasil.fromJson(Map<String, dynamic> json) {
    return ReportHasil(
      isGood: json['isGood'] == 1,
      imageUrl: json['imageUrl'],
      title: json['title'],
      composition: json['composition'],
      nutritionInfo: json['nutritionInfo'],
      currentCalories: json['currentCalories'],
      totalCalories: json['totalCalories'],
    );
  }
}