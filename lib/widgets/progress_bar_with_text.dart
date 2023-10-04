import 'package:flutter/material.dart';

class ProgressBarWithText extends StatelessWidget {
  final int current;
  final int total;

  ProgressBarWithText({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: current / total.toDouble(),
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 10),
        Text(
          "$current / $total",
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
