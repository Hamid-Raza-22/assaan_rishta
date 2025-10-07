import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_colors.dart';

class TutorialCard extends StatelessWidget {
  final String title;
  final String description;
  final String thumbnail;
  final String url;

  const TutorialCard({
    super.key,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.url,
  });

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // ClipRRect(
                //   borderRadius: const BorderRadius.vertical(
                //     top: Radius.circular(16),
                //   ),
                //   child: Image.network(
                //     thumbnail,
                //     height: 180,
                //     width: double.infinity,
                //     fit: BoxFit.cover,
                //     errorBuilder: (context, error, stackTrace) {
                //       return Container(
                //         height: 180,
                //         color: Colors.grey[300],
                //         child: const Icon(
                //           Icons.play_circle_outline,
                //           size: 60,
                //           color: Colors.white,
                //         ),
                //       );
                //     },
                //   ),
                // ),
                // Positioned.fill(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.black.withOpacity(0.3),
                //       borderRadius: const BorderRadius.vertical(
                //         top: Radius.circular(16),
                //       ),
                //     ),
                //     child: const Center(
                //       child: Icon(
                //         Icons.play_circle_filled,
                //         size: 60,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Watch Tutorial',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color:AppColors.primaryColor,
                      ),
                    ],
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