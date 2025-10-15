import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQItemController extends GetxController {
  final expanded = false.obs;

  void toggleExpanded() {
    expanded.value = !expanded.value;
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  final String? url; // Optional URL field

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
    this.url,
  });

  Future<void> _launchUrl() async {
    if (url != null && url!.isNotEmpty) {
      final Uri uri = Uri.parse(url!);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      FAQItemController(),
      tag: question,
    );

    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: controller.toggleExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Obx(() => Icon(
                    controller.expanded.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  )),
                ],
              ),
              Obx(() => AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      // Show link button if URL exists
                      if (url != null && url!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _launchUrl,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.open_in_new,
                                size: 16,
                                color: Colors.pinkAccent,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Watch Tutorial',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pinkAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                crossFadeState: controller.expanded.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              )),
            ],
          ),
        ),
      ),
    );
  }
}