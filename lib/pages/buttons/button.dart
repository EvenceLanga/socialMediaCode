import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  const MyButton({Key? key, this.onTap, required this.text}) : super(key: key);

  final Function()? onTap;
  final String text;

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Use widget.onTap here
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
