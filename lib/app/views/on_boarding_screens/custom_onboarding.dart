import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'controller.dart';
import '../../widgets/app_text.dart';

class CustomOnboardingPage extends StatefulWidget {
  final String video;
  final String title;
  final String subtitle;
  final int index;

  const CustomOnboardingPage({
    super.key,
    required this.video,
    required this.title,
    required this.subtitle,
    required this.index,
  });

  @override
  State<CustomOnboardingPage> createState() => _CustomOnboardingPageState();
}

class _CustomOnboardingPageState extends State<CustomOnboardingPage> {
  late VideoPlayerController _controller;
  final OnboardingController onboardingController = Get.find();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(false);

        // 🔹 When video completes, go to next page
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration &&
              !_controller.value.isPlaying) {
            onboardingController.goToNextPage();
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🟩 Title
          // const SizedBox(height: 4),
          const SizedBox(height: 4),
          AppText(
            text: widget.title,
            textAlign: TextAlign.center,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            maxLines: 3,
          ),
          const SizedBox(height: 8),

          // 🟦 Subtitle
          AppText(
            text: widget.subtitle,
            textAlign: TextAlign.center,
            fontSize: 16,
            color: Colors.black54,
            maxLines: 5,
          ),

          const SizedBox(height: 20),

          // 🎥 Big Frame for Video
          Expanded(
            child: Center(
              child: Container(
                width: size.width * 0.95,
                height: size.height * 0.95,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade700,
                    width: 8,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      color: Colors.black,
                      child: _controller.value.isInitialized
                          ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      )
                          : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
