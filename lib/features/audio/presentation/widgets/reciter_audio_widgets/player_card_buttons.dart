import 'package:flutter/material.dart';

class PlayerCardButtons extends StatelessWidget {
  const PlayerCardButtons({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 24),
      label: Text(text),
    );
  }
}
