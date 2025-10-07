import 'package:assaan_rishta/app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Sub Tab Bar Widget - GetX Compatible
/// Horizontal scrollable pills ke liye (Generic Questions, Security, etc.)
class SubTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;

  const SubTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final selected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? Colors.pink[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? AppColors.primaryColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selected ? Colors.pinkAccent : Colors.black87,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}