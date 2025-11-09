import 'package:flutter/material.dart';
import 'package:diary_for_me/timeline/screen/event_list_screen.dart';

class PurpleButton extends StatelessWidget {
  final String text;
  final DateTime date;
  const PurpleButton({super.key, required this.text, required this.date});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventListScreen(date: date)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8C6FF7),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
