import 'package:get/get.dart';

class UserGuideController extends GetxController {
  // Observable variables
  final selectedMainTab = 0.obs;
  final selectedSubTab = 0.obs;

  // Constants
  final List<String> mainTabs = ["FAQs", "Tutorials"];
  final List<String> subTabs = [
    "Generic Questions",
    "Security Questions",
    "Refund Policy"
  ];

  // Tutorial Data
  final List<Map<String, String>> tutorialData = [
    {
      "title": "Getting Started with Asaan Rishta",
      "description": "Learn how to create your profile and start your journey",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://youtu.be/L0ZHFc6vUQg"
    },
    {
      "title": "How to Send Interest & Connect",
      "description": "Step by step guide to connect with potential matches",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@falakaxe/video/7556688704845122824"
    },
    {
      "title": "Privacy & Safety Tips",
      "description": "Important safety guidelines for a secure experience",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://youtube.com/watch?v=example3"
    },
  ];

  // FAQ Data
  final Map<String, List<Map<String, String>>> faqData = {
    "Generic Questions": [
      {
        "q": "How can I use Asaan Rishta?",
        "a": "You can browse profiles, send interests, and connect with verified users directly through the app."
      },
      {
        "q": "Is registration free?",
        "a": "Yes, registration is free. However, premium plans unlock extra features such as chat and advanced search."
      },
      {
        "q": "How do I create my account?",
        "a": "Open the app, tap on 'Create Account', and fill in your basic details such as name, age, and profession."
      },
      {
        "q": "How can I create a connection?",
        "a": "You can send an interest request or accept one. Once both users agree, a connection is created."
      },
      {
        "q": "Is there an expiry date for the package?",
        "a": "Yes, each subscription package has a specific validity period mentioned before you buy."
      },
      {
        "q": "What if I don't get a reply from the other side?",
        "a": "Please be patient. Not everyone is active daily. You can also try reaching out to other matches."
      },
    ],
    "Security Questions": [
      {
        "q": "How can I report or block users?",
        "a": "Open the user's profile, tap the three-dot menu, and choose 'Report' or 'Block'."
      },
      {
        "q": "Should I share my personal information?",
        "a": "Never share sensitive details like your address or banking info. Use in-app chat for safety."
      },
      {
        "q": "How can I manage users I'm not interested in?",
        "a": "You can either hide their profile or block them from viewing your account."
      },
    ],
    "Refund Policy": [
      {
        "q": "Can I get my money back?",
        "a": "Refunds are generally not offered, but you can contact support for exceptional cases."
      },
    ],
  };

  // Getters
  String get currentSubTab => subTabs[selectedSubTab.value];
  List<Map<String, String>> get currentFaqs => faqData[currentSubTab] ?? [];
  List<Map<String, String>> get tutorials => tutorialData;

  // Methods
  void changeMainTab(int index) {
    selectedMainTab.value = index;
  }

  void changeSubTab(int index) {
    selectedSubTab.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize any data if needed
  }

  @override
  void onClose() {
    super.onClose();
    // Clean up resources
  }
}