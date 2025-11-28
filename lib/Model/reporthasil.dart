import 'dart:convert';
import 'package:http/http.dart';
import 'package:eatwise2/util/config.dart';

class ReportHasil {
  final String imageUrl, title, nutritionInfo;
  final int currentCalories, totalCalories;
  final bool isGood;
  final List<String> composition;
  final Map<String, double>? risikoPersentase; // Tambahkan ini
  
  ReportHasil({
    required this.isGood,
    required this.imageUrl,
    required this.title,
    required this.composition,
    required this.nutritionInfo,
    required this.currentCalories,
    required this.totalCalories,
    this.risikoPersentase, // Tambahkan ini
  });

  factory ReportHasil.fromJson(Map<String, dynamic> json) {
    return ReportHasil(
      isGood: json['isGood'] == 1,
      imageUrl: json['imageUrl'],
      title: json['title'],
      composition: List<String>.from(json['composition'] ?? []),
      nutritionInfo: json['nutritionInfo'],
      currentCalories: json['currentCalories'],
      totalCalories: json['totalCalories'],
      risikoPersentase: json['risikoPersentase'] != null 
          ? Map<String, double>.from(json['risikoPersentase'])
          : null,
    );
  }
}