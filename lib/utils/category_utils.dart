import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryUtils {
  static const Map<String, IconData> categoryIcons = {
    'Food': FontAwesomeIcons.burger,
    'Transport': FontAwesomeIcons.bus,
    'Shopping': FontAwesomeIcons.bagShopping,
    'Bills': FontAwesomeIcons.fileInvoiceDollar,
    'Entertainment': FontAwesomeIcons.film,
    'Health': FontAwesomeIcons.heartPulse,
    'Travel': FontAwesomeIcons.plane,
    'General': FontAwesomeIcons.moneyBill,
  };

  static const Map<String, Color?> categoryColors = {
    'Food': Colors.orangeAccent,
    'Transport': Colors.blueAccent,
    'Shopping': Colors.pinkAccent,
    'Bills': Colors.redAccent,
    'Entertainment': Colors.purpleAccent,
    'Health': Colors.greenAccent,
    'Travel': Colors.tealAccent,
    'General': Colors.grey,
  };

  static IconData getIcon(String category) {
    return categoryIcons[category] ?? FontAwesomeIcons.circleQuestion;
  }

  static Color getColor(String category) {
    return categoryColors[category] ?? Colors.blueGrey;
  }

  static List<String> get categories => categoryIcons.keys.toList();
}
