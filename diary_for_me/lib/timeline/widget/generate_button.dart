import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/timeline/screen/event_list_screen.dart';
import 'package:diary_for_me/common/ui_kit.dart';

class GenerateButton extends StatefulWidget {
  final DateTime date;

  const GenerateButton({super.key, required this.date});

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton> {
  @override
  Widget build(BuildContext context) {
    return ContainerButton(
      borderRadius: BorderRadius.circular(20),
      color: themeColor,
      height: 56,
      shadows: [
        BoxShadow(
          color: themeColor.withAlpha(128),
          spreadRadius: -12,
          blurRadius: 18,
          offset: Offset(0, 18),
        ),
      ],
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EventListScreen(date: widget.date)),
        );
      },
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('일기 생성하기', style: mainButton()),
            Icon(Icons.navigate_next, size: 24, color: Colors.white),
          ],
        ),
      ),
    );
  }
}


/*
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

 */