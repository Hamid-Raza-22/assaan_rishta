import 'package:flutter/material.dart';

import '../utils/exports.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  void _toggleCheckbox() {
    setState(() {
      _value = !_value;
      widget.onChanged(_value); // Trigger the onChanged callback
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCheckbox,
      child: Container(
        height: 20,
        width: 20,
        margin: const EdgeInsets.only(top: 05),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(02),
          border: Border.all(
            color: AppColors.borderColor,
          ),
        ),
        child: _value
            ? const Icon(
                Icons.check,
                size: 15,
              )
            : null,
      ),
    );
  }
}
