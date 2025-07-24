import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String hint;
  final List<String> items;
  final String value;
  final Function(String?) onChanged;

  const DropdownField({
    super.key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: Text(hint, style: TextStyle(color: Colors.grey[500])),
        icon: const Icon(Icons.arrow_drop_down),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
