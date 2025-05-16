// import 'package:flutter/material.dart';

// 


class MealInfo
{
  MealInfo(this.carbonhydrate_g, this.protein_g, this.fat_g, this.sodium_mg, this.cellulose_g, this.sugar_g, this.cholesterol_mg, {
    required this.intaketime, 
    required this.mealtype,
    required this.intakeamount,
    required this.meals,
  });

  final List<String> meals;
  final DateTime intaketime;
  final String mealtype;
  final int intakeamount;

  final double protein_g;
  final double fat_g;
  final double carbonhydrate_g;
  final double sugar_g;
  final double cellulose_g;
  final double sodium_mg;
  final double cholesterol_mg;
}