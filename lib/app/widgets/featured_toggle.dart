import 'package:flutter/material.dart';
import '../utils/exports.dart';
import 'app_text.dart';

/// A modern, AI-themed featured toggle button widget
/// Can be used as a button (for app bar) or as a toggle switch (for filter page)
class FeaturedToggle extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;
  final bool isCompact;
  final bool showLabel;

  const FeaturedToggle({
    super.key,
    required this.isEnabled,
    required this.onTap,
    this.isCompact = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactButton();
    }
    return _buildFullToggle();
  }

  /// Compact button for app bar usage
  Widget _buildCompactButton() {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.secondaryColor,
                  ],
                )
              : null,
          color: isEnabled ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnabled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isEnabled ? Colors.white : Colors.grey.shade600,
              size: 18,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                'Featured',
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Full toggle for filter page usage
  Widget _buildFullToggle() {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.secondaryColor,
                  ],
                )
              : null,
          color: isEnabled ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? Colors.transparent
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                    color: isEnabled ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Profiles',
                      style: TextStyle(
                        color: isEnabled ? Colors.white : Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled ? 'Showing top picks' : 'Show premium matches',
                      style: TextStyle(
                        color: isEnabled
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: isEnabled
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isEnabled ? 26 : 2,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isEnabled ? Colors.white : Colors.grey.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isEnabled ? Icons.check : Icons.close,
                        size: 14,
                        color: isEnabled
                            ? AppColors.primaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An AI-themed featured chip with switch for inline usage
class FeaturedChip extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const FeaturedChip({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            const AppText(
              text: 'Featured',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(width: 8),
            // Mini Switch - only this changes
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: isEnabled
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: isEnabled ? 18 : 2,
                    top: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        isEnabled ? Icons.check : Icons.close,
                        size: 10,
                        color: isEnabled ? AppColors.greenColor : AppColors.redColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
