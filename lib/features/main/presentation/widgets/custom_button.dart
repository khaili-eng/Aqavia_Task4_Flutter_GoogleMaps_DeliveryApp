import 'package:flutter/material.dart';

import '../../../../core/color/app_color.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  const CustomButton({super.key,
    required this.title, 
    this.color = AppColor.buttonMainColor, 
     this.textColor = Colors.black12, 
    required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          )
        ),
        child: Text(title,style: TextStyle(color: textColor,fontWeight: FontWeight.w600,fontSize: 16),));
  }
}
