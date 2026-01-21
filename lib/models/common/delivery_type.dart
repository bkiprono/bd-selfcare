import 'package:flutter/material.dart';
import 'package:bdcomputing/enums/fuel_delivery_type_enums.dart';

class DeliveryTypeData {
  final FuelDeliveryTypeEnum id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String note;

  DeliveryTypeData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.note,
  });
}
