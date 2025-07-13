import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../viewmodels/signup_viewmodel.dart';


class GenderSelector extends StatelessWidget {
  final SignupViewModel controller;

  const GenderSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'Male',
              groupValue: controller.selectedGender.value,
              onChanged: (value) => controller.selectGender(value!),
              activeColor: Colors.blue,
            ),
            Text(
              'Male',
              style: TextStyle(
                color: controller.selectedGender.value == 'Male'
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Female',
              groupValue: controller.selectedGender.value,
              onChanged: (value) => controller.selectGender(value!),
              activeColor: Colors.pink,
            ),
            Text(
              'Female',
              style: TextStyle(
                color: controller.selectedGender.value == 'Female'
                    ? Colors.pink
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
