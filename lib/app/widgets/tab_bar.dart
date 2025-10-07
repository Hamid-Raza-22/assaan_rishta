import 'package:flutter/material.dart';

/// Custom Tab Bar Widget - GetX Compatible
/// Main tabs ke liye (FAQs, Tutorials, etc.)
class CustomTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (i) {
          final selected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: selected ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: 60,
                  decoration: BoxDecoration(
                    color: selected ? Colors.pinkAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}