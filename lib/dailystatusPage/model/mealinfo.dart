// import 'package:flutter/material.dart';

class MealInfo
{
  MealInfo({
    required this.carbonhydrate_g,
    required this.protein_g,
    required this.fat_g,
    required this.sodium_mg,
    required this.cellulose_g,
    required this.sugar_g,
    required this.cholesterol_mg,
    required this.intaketime, 
    required this.mealtype,
    required this.intakeamount,
    required this.meals,
    required this.imagepath,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      carbonhydrate_g: (json['carbonhydrate_g'] as num).toDouble(),
      protein_g: (json['protein_g'] as num).toDouble(),
      fat_g: (json['fat_g'] as num).toDouble(),
      sodium_mg: (json['sodium_mg'] as num).toDouble(),
      cellulose_g: (json['cellulose_g'] as num).toDouble(),
      sugar_g: (json['sugar_g'] as num).toDouble(),
      cholesterol_mg: (json['cholesterol_mg'] as num).toDouble(),
      intaketime: DateTime.parse(json['intaketime']),
      mealtype: json['mealtype'] as String,
      intakeamount: json['intakeamount'] as int,
      meals: List<String>.from(json['meals']),
      imagepath: json['imagepath'] as String,
    );
  }

  final List<String> meals;
  final DateTime intaketime;
  final String mealtype;
  final int intakeamount;
  final String imagepath;

  final double protein_g;
  final double fat_g;
  final double carbonhydrate_g;
  final double sugar_g;
  final double cellulose_g;
  final double sodium_mg;
  final double cholesterol_mg;
}