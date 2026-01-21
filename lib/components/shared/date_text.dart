import 'package:flutter/material.dart';

class DateText extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;
  final TextAlign? textAlign;

  const DateText({super.key, required this.date, this.style, this.textAlign});

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final formatted =
        "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)}, ${date.year}";
    return Text(
      formatted,
      style: style ?? TextStyle(fontSize: 14, color: Colors.grey[600]),
      textAlign: textAlign,
    );
  }
}
