import 'package:flutter/material.dart';
import 'package:bdcomputing/models/fuel/fuel_product.dart';

class FuelProductWithIcon {
  final FuelProduct fuelProduct;
  final IconData icon;
  final Color iconColor;

  FuelProductWithIcon({
    required this.fuelProduct,
    required this.icon,
    required this.iconColor,
  });
}
