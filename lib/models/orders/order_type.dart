import 'package:flutter/material.dart';
import 'package:bdcomputing/enums/fuel_order_type_enums.dart';

class OrderTypeData {
  final FuelOrderTypeEnum id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  OrderTypeData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}
