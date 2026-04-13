import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/exports.dart';

/// Professional animated success overlay for login
class ProfessionalSuccessOverlay {
  static OverlayEntry? _overlayEntry;

  static void show({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Delay to ensure overlay is ready after navigation/build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(title: title, message: message, duration: duration);
    });
  }

  static void _showOverlay({
    required String title,
    required String message,
    required Duration duration,
  }) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayEntry = OverlayEntry(
      builder: (context) => _SuccessOverlayWidget(
        title: title,
        message: message,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        duration: duration,
      ),
    );

    // Use Get.key (GetMaterialApp's navigator key) for reliable overlay access
    final overlayState = Get.key.currentState?.overlay;
    if (overlayState != null && _overlayEntry != null) {
      overlayState.insert(_overlayEntry!);
      return;
    }

    // Fallback to GetX snackbar if overlay not available
    _overlayEntry = null;
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.greenColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: duration,
    );
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _SuccessOverlayWidget extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;
  final Duration duration;

  const _SuccessOverlayWidget({
    required this.title,
    required this.message,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_SuccessOverlayWidget> createState() => _SuccessOverlayWidgetState();
}

class _SuccessOverlayWidgetState extends State<_SuccessOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _checkController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    // Scale animation for icon container
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.bounceOut),
    );

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _checkController.forward();
        });
      }
    });

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _slideController.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _checkController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.greenColor,
                  AppColors.greenColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.greenColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated checkmark
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _CheckMarkPainter(
                            progress: _checkAnimation.value,
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Sparkle icon
                _SparkleWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom check mark painter with animation
class _CheckMarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckMarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Check mark path
    final startPoint = Offset(size.width * 0.25, size.height * 0.5);
    final midPoint = Offset(size.width * 0.45, size.height * 0.7);
    final endPoint = Offset(size.width * 0.75, size.height * 0.35);

    path.moveTo(startPoint.dx, startPoint.dy);
    
    if (progress <= 0.5) {
      // First part of check
      final t = progress * 2;
      final currentPoint = Offset(
        startPoint.dx + (midPoint.dx - startPoint.dx) * t,
        startPoint.dy + (midPoint.dy - startPoint.dy) * t,
      );
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Complete first part
      path.lineTo(midPoint.dx, midPoint.dy);
      
      // Second part of check
      final t = (progress - 0.5) * 2;
      final currentPoint = Offset(
        midPoint.dx + (endPoint.dx - midPoint.dx) * t,
        midPoint.dy + (endPoint.dy - midPoint.dy) * t,
      );
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Sparkle animation widget
class _SparkleWidget extends StatefulWidget {
  @override
  State<_SparkleWidget> createState() => _SparkleWidgetState();
}

class _SparkleWidgetState extends State<_SparkleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: 0.8 + (_animation.value * 0.2),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

/// Professional Logout Loading Dialog with animations
class ProfessionalLogoutDialog {
  static void show() {
    Get.dialog(
      const _LogoutLoadingWidget(),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  static void dismiss() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

class _LogoutLoadingWidget extends StatefulWidget {
  const _LogoutLoadingWidget();

  @override
  State<_LogoutLoadingWidget> createState() => _LogoutLoadingWidgetState();
}

class _LogoutLoadingWidgetState extends State<_LogoutLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for dialog entry
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Rotation for the icon
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Pulse animation for the container
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dots animation
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated logout icon
                      _buildAnimatedLogoutIcon(),
                      const SizedBox(height: 24),
                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.7),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Logging Out',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Animated dots
                      _buildAnimatedDots(),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text(
                        'Please wait while we secure your session',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogoutIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating ring
        RotationTransition(
          turns: _rotateController,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.3),
                  AppColors.primaryColor.withOpacity(0.1),
                  AppColors.primaryColor,
                ],
              ),
            ),
          ),
        ),
        // Inner circle with icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            Icons.logout_rounded,
            size: 28,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final progress = (_dotsController.value + delay) % 1.0;
            final opacity = (1 - (progress - 0.5).abs() * 2).clamp(0.3, 1.0);
            final scale = 0.8 + (opacity * 0.4);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
