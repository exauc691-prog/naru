import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const card = 20.0;
  static const button = 14.0;
  static const field = 14.0;
  static const modal = 28.0;

  static const smallBorderRadius = BorderRadius.all(Radius.circular(small));
  static const mediumBorderRadius = BorderRadius.all(Radius.circular(medium));
  static const largeBorderRadius = BorderRadius.all(Radius.circular(large));
  static const cardBorderRadius = BorderRadius.all(Radius.circular(card));
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(button));
  static const fieldBorderRadius = BorderRadius.all(Radius.circular(field));
  static const modalBorderRadius = BorderRadius.all(Radius.circular(modal));
}
