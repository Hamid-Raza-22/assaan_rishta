import 'package:flutter/material.dart';

import '../utils/exports.dart';
import 'export.dart';

class CustomRadioBox extends StatefulWidget {
  final String text;
  final bool value;
  final bool groupValue;
  final ValueChanged<bool> onChanged;

  const CustomRadioBox({
    super.key,
    required this.text,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  _CustomRadioBoxState createState() => _CustomRadioBoxState();
}

class _CustomRadioBoxState extends State<CustomRadioBox> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  void _selectRadio() {
    if (_value != widget.groupValue) {
      widget.onChanged(true); // Only trigger change if it's not the current selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectRadio,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.groupValue == _value
                    ? AppColors.secondaryColor
                    : AppColors.fontLightColor, // Change color based on selected state
              ),
            ),
            child: widget.groupValue == _value
                ? const Icon(
              Icons.circle,
              size: 15,
              color: AppColors.secondaryColor,
            )
                : null,
          ),
          const SizedBox(width: 10),
          AppText(
            text: widget.text,
            color: AppColors.fontLightColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
