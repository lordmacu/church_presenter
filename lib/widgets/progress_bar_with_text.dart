import 'package:flutter/material.dart';

class ProgressBarWithText extends StatelessWidget {
  final int current;
  final int total;

  const ProgressBarWithText(
      {Key? key, required this.current, required this.total})
      : super(key: key);

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
        const SizedBox(width: 10),
        Text(
          "$current / $total",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
