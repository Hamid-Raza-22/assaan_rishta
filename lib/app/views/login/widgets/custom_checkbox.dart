import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onChanged;

  const CustomCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isChecked ? Colors.red : Colors.transparent,
          border: Border.all(
            color: isChecked ? Colors.red : Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isChecked
            ? const Icon(
          Icons.check,
          color: Colors.white,
          size: 14,
        )
            : null,
      ),
    );
  }
}
