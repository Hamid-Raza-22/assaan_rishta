import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import '../utils/app_utils.dart';

class TypingIndicator extends StatefulWidget {
  final bool isVisible;
  final String userName;
  final String userAvatarUrl; // Add this parameter

  const TypingIndicator({
    super.key,
    required this.isVisible,
    required this.userName,
    required this.userAvatarUrl, // Add this required parameter
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.isVisible
          ? Container(
        key: const ValueKey('typing_indicator'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // User Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: 30,
                width: 30,
                imageUrl: AppUtils.sanitizeImageUrl(widget.userAvatarUrl),
                errorWidget: (c, url, e) => Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    CupertinoIcons.person,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
                placeholder: (c, url) => Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    CupertinoIcons.person,
                    color: Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 8),
            // Text(
            //   'is typing',
            //   style: GoogleFonts.poppins(
            //     fontSize: 13,
            //     color: Colors.grey[600],
            //     fontStyle: FontStyle.italic,
            //   ),
            // ),
            const SizedBox(width: 8),
            _buildDots(),
          ],
        ),
      )
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_animation.value - delay).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[600]?.withOpacity(0.3 + (value * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}