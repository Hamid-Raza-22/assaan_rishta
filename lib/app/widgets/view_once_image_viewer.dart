
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:no_screenshot/no_screenshot.dart';

import '../core/models/chat_model/message.dart';

class ViewOnceImageViewer extends StatefulWidget {
  final Message message;
  final VoidCallback onViewed;

  const ViewOnceImageViewer({
    super.key,
    required this.message,
    required this.onViewed,
  });

  @override
  State<ViewOnceImageViewer> createState() => _ViewOnceImageViewerState();
}

class _ViewOnceImageViewerState extends State<ViewOnceImageViewer> {
  final _noScreenshot = NoScreenshot.instance;
  bool _hasViewed = false;
  int _secondsRemaining = 25; // Auto-close after 10 seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _markAsViewed();
    _toggleScreenshotProtection(true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        _closeViewer();
      }
    });
  }

  void _markAsViewed() async {
    if (!_hasViewed) {
      _hasViewed = true;
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onViewed();
    }
  }

  void _closeViewer() {
    _timer?.cancel();
    Navigator.pop(context);
    _toggleScreenshotProtection(false);
  }

  Future<void> _toggleScreenshotProtection(bool enable) async {
    try {
      if (enable) {
        await _noScreenshot.screenshotOff();
      } else {
        await _noScreenshot.screenshotOn();
      }
    } catch (e) {
      debugPrint('Failed to toggle screenshot protection: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image
          Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const CircularProgressIndicator(
                  color: Colors.white,
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

          // Top bar with timer
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _closeViewer,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timelapse,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_secondsRemaining s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Text(
                '📸 This photo will disappear after viewing',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}