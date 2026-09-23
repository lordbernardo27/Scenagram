import 'package:flutter/material.dart';

class CustomShareAction extends StatelessWidget {
  const CustomShareAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(
          Icons.auto_awesome_outlined,
          size: 28,
          color: Color(0xFF4B5563),
        ),
        SizedBox(width: 8),
        Text(
          'Share',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
