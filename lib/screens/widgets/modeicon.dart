import 'package:flutter/material.dart';

class ToggleExample extends StatefulWidget {
  const ToggleExample({super.key});

  @override
  State<ToggleExample> createState() => _ToggleExampleState();
}

class _ToggleExampleState extends State<ToggleExample> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
          value: isOn,
          activeColor: Colors.green, // Color when ON
          inactiveTrackColor: const Color(0xFF3A3C45), // Track color when OFF
          inactiveThumbColor: const Color(0xFF5A5C65), // Circle color when OFF
          onChanged: (value) {
            setState(() {
              isOn = value;
            });
          },
        
    );
  }
}