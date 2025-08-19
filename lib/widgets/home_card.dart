import 'package:flutter/material.dart';

class CustomSquareCard extends StatelessWidget {
  final String title;
  final String centerText;

  const CustomSquareCard({
    Key? key,
    required this.title,
    required this.centerText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 4, // Adds shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Slightly rounded edges
        ),
        child: Container(
          width: 150,
          height: 150,
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerText,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
