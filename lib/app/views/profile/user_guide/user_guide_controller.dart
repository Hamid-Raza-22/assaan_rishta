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
    // Getting Started
    {
      "title": "Getting Started with Asaan Rishta",
      "description": "Learn how to create your profile and start your journey",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7559971030136048899"
    },

    // Sign Up & Login
    {
      "title": "How to Sign Up on Asaan Rishta",
      "description": "Complete step-by-step guide to create your account",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7561805772800265494"
      // "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560589386698493186"
    },
    {
      "title": "Login Process - Asaan Rishta App",
      "description": "Easy login steps to access your account",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560591046523260162"
    },

    // Profile Management
    {
      "title": "Viewing User Profile Details",
      "description": "How to view and explore other users' profiles",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560592141735431446"
    },
    {
      "title": "Edit & Update Your Profile",
      "description": "Learn how to modify your profile information",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560601466507988226"
    },
    {
      "title": "Change Your Profile Picture",
      "description": "Step-by-step guide to update your profile photo",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560603662754647298"
    },

    // Finding Matches
    {
      "title": "Apply Filters to Find Matches",
      "description": "Use advanced filters to find your perfect match",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560605141712243990"
    },
    {
      "title": "Modify Partner Preferences",
      "description": "How to update your partner preference settings",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560599504580300054"
    },

    // Interactions
    // {
    //   "title": "How to Send Interest & Connect",
    //   "description": "Step by step guide to connect with potential matches",
    //   "thumbnail": "https://via.placeholder.com/150",
    //   "url": "https://www.tiktok.com/@falakaxe/video/7556688704845122824"
    // },
    {
      "title": "How to Chat with User",
      "description": "Learn how to start and manage conversations",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560609325270437142"
    },
    {
      "title": "How to Share a User Profile",
      "description": "Share interesting profiles with friends and family",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560594459486866710"
    },
    {
      "title": "Add Profiles to Favorites",
      "description": "Save your favorite profiles for easy access",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560595362898021654"
    },

    // Connects & Payments
    {
      "title": "All Payment Methods Overview",
      "description": "Complete guide to all available payment options",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7561825639393742102"
    },
    // {
    //   "title": "Buy & Manage Your Connects",
    //   "description": "Learn how to purchase and manage Connects",
    //   "thumbnail": "https://via.placeholder.com/150",
    //   "url": "https://youtube.com/watch?v=connects_example"
    // },
    {
      "title": "Payment with Google Pay",
      "description": "Complete guide for Google Pay payment method",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560612702578576663"
    },
    {
      "title": "Payment through PayFast",
      "description": "How to complete payment using PayFast",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560613616601419030"
    },
    {
      "title": "Manual Payment Process",
      "description": "Step-by-step guide for manual payment method",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560614669191302403"
    },

    // Account Security
    {
      "title": "Keep Your Connections Safe",
      "description": "Learn how to protect and manage your connections securely",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560615913758657814"
    },
    {
      "title": "Reset or Change Your Password",
      "description": "How to securely reset or update your password",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560607755548069142"
    },
    {
      "title": "How to Logout from Your Account",
      "description": "Safe logout process from Asaan Rishta app",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560618317732531478"
    },
    {
      "title": "How to Delete Your Account",
      "description": "Complete guide to permanently delete your account",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560617108816563478"
    },
    {
      "title": "Report Suspicious or Fake Profiles",
      "description": "Learn how to report and block suspicious users",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560606360770006294"
    },

    // Safety
    // {
    //   "title": "Privacy & Safety Tips",
    //   "description": "Important safety guidelines for a secure experience",
    //   "thumbnail": "https://via.placeholder.com/150",
    //   "url": "https://youtube.com/watch?v=example3"
    // },

    // Additional Features
    {
      "title": "View Vendor Profiles",
      "description": "Explore and review vendor profiles in detail",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560602629160602902"
    },
    {
      "title": "User Guide Section Description",
      "description": "Complete overview of all features and sections",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560585686475115798"
    },
    {
      "title": "Features for User in Guest Mode",
      "description": "Explore what you can do without logging in",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560588528883731734"
    },
    {
      "title": "How to Share a Vendor Profile",
      "description": "Share interesting profiles with friends and family",
      "thumbnail": "https://via.placeholder.com/150",
      "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7562150281358626070"
    },
  ];
  final Map<String, List<Map<String, String>>> faqData = {
    "Generic Questions": [
      {
        "q": "How can I use Asaan Rishta??",
        "a": "You can browse profiles, send interests, and connect with verified users directly through the app.",
        "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560649875545722134"
      },
    ],
    "Security Questions": [
      {
        "q": "if someone is being rude or using inappropriate language while chatting, how should I handle this situation? Should I block the user or report their profile?",
        "a": "Open the user's profile, tap the three-dot menu, and choose 'Report' or 'Block'.",
        "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560651583831215382"
      },
      {
        "q": "Should I share my personal information?",
        "a": "Never share sensitive details like your address or banking info. Use in-app chat for safety.",
        "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560655400593329430"
      },
      {
        "q": "How can I manage users I'm not interested in?",
        "a": "You can either hide their profile or block them from viewing your account.",
        "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560652967112674582"
      },
    ],
    "Refund Policy": [
      {
        "q": "Can I get my money back?",
        "a": "Refunds are generally not offered, but you can contact support for exceptional cases.",
        "url": "https://www.tiktok.com/@asaanrishtaofficial0/video/7560662986826763542"
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