import 'package:flutter/material.dart';

class AppTextFormFeild extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final IconData icon;
  final TextInputType keyboardType;
  const AppTextFormFeild({super.key,
    required this.controller,
    required this.label,
     this.isPassword=false,
    required this.icon,
     this.keyboardType=TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: (value){
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)
        )
      ),
    ),);
  }
}
