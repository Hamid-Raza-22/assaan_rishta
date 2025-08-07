// message_status_indicator.dart - Widget to show message status

import 'package:flutter/material.dart';

import '../../core/models/chat_model/message.dart';

class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final bool isFromCurrentUser;

  const MessageStatusIndicator({
    Key? key,
    required this.status,
    required this.isFromCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show status for messages sent by current user
    if (!isFromCurrentUser) {
      return const SizedBox.shrink();
    }

    Widget statusIcon;

    switch (status) {
      case MessageStatus.sending:
      // Clock icon for sending
        statusIcon = const Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey,
        );
        break;

      case MessageStatus.sent:
      // Single gray tick
        statusIcon = const Icon(
          Icons.done,
          size: 16,
          color: Colors.grey,
        );
        break;

      case MessageStatus.delivered:
      // Double gray ticks
        statusIcon = const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey,
        );
        break;

      case MessageStatus.read:
      // Double blue ticks
        statusIcon = const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: statusIcon,
    );
  }
}

// Alternative implementation with custom double tick design
class CustomMessageStatus extends StatelessWidget {
  final MessageStatus status;
  final bool isFromCurrentUser;

  const CustomMessageStatus({
    Key? key,
    required this.status,
    required this.isFromCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isFromCurrentUser) {
      return const SizedBox.shrink();
    }

    switch (status) {
      case MessageStatus.sending:
        return Container(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        );

      case MessageStatus.sent:
        return CustomPaint(
          size: const Size(16, 16),
          painter: TickPainter(
            color: Colors.grey[600]!,
            doubleCheck: false,
          ),
        );

      case MessageStatus.delivered:
        return CustomPaint(
          size: const Size(20, 16),
          painter: TickPainter(
            color: Colors.grey[600]!,
            doubleCheck: true,
          ),
        );

      case MessageStatus.read:
        return CustomPaint(
          size: const Size(20, 16),
          painter: TickPainter(
            color: Colors.blue,
            doubleCheck: true,
          ),
        );
    }
  }
}

// Custom painter for tick marks
class TickPainter extends CustomPainter {
  final Color color;
  final bool doubleCheck;

  TickPainter({
    required this.color,
    required this.doubleCheck,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // First tick
    final path1 = Path();
    path1.moveTo(size.width * 0.2, size.height * 0.5);
    path1.lineTo(size.width * 0.4, size.height * 0.7);
    path1.lineTo(size.width * 0.65, size.height * 0.3);
    canvas.drawPath(path1, paint);

    // Second tick (if double check)
    if (doubleCheck) {
      final path2 = Path();
      path2.moveTo(size.width * 0.45, size.height * 0.5);
      path2.lineTo(size.width * 0.65, size.height * 0.7);
      path2.lineTo(size.width * 0.9, size.height * 0.3);
      canvas.drawPath(path2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}