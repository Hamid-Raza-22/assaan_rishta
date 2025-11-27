import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var secureTextField: UITextField?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Setup screen security method channel
    setupScreenSecurityChannel()
    
    // Register for remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          if granted {
            print("✅ iOS Notification permission granted")
          } else {
            print("❌ iOS Notification permission denied: \(String(describing: error))")
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    // Set FCM messaging delegate
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle FCM token registration
  override func application(_ application: UIApplication, 
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNs device token registered")
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // Handle notification tap when app is in background/terminated
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("📱 Notification tapped: \(userInfo)")
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    print("📬 Notification received in foreground: \(userInfo)")
    
    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .sound, .badge]])
    } else {
      completionHandler([[.alert, .sound, .badge]])
    }
  }
}

// MARK: - FCM Token Handling
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔑 Firebase FCM token: \(String(describing: fcmToken))")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// MARK: - Screen Security
extension AppDelegate {
  private func setupScreenSecurityChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "com.asaanrishta.app/screen_security",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "enableScreenSecurity":
        self?.enableScreenSecurity()
        result(true)
      case "disableScreenSecurity":
        self?.disableScreenSecurity()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func enableScreenSecurity() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self,
            let window = self.window else { return }
      
      // Remove existing secure field if any
      self.secureTextField?.removeFromSuperview()
      
      // Create a secure text field that covers the entire window
      // This prevents screenshots on iOS
      let textField = UITextField()
      textField.isSecureTextEntry = true
      textField.isUserInteractionEnabled = false
      textField.frame = window.bounds
      textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      // Insert at the very back so it doesn't interfere with UI
      window.insertSubview(textField, at: 0)
      window.layer.superlayer?.addSublayer(textField.layer)
      textField.layer.sublayers?.first?.addSublayer(window.layer)
      
      self.secureTextField = textField
      
      // Also add screenshot notification observer
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.userDidTakeScreenshot),
        name: UIApplication.userDidTakeScreenshotNotification,
        object: nil
      )
      
      // Screen recording observer
      if #available(iOS 11.0, *) {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.screenCaptureChanged),
          name: UIScreen.capturedDidChangeNotification,
          object: nil
        )
      }
      
      print("🔒 Screen security enabled on iOS")
    }
  }
  
  private func disableScreenSecurity() {
    DispatchQueue.main.async { [weak self] in
      self?.secureTextField?.removeFromSuperview()
      self?.secureTextField = nil
      
      NotificationCenter.default.removeObserver(
        self as Any,
        name: UIApplication.userDidTakeScreenshotNotification,
        object: nil
      )
      
      if #available(iOS 11.0, *) {
        NotificationCenter.default.removeObserver(
          self as Any,
          name: UIScreen.capturedDidChangeNotification,
          object: nil
        )
      }
      
      print("🔓 Screen security disabled on iOS")
    }
  }
  
  @objc private func userDidTakeScreenshot() {
    print("⚠️ Screenshot detected!")
    // You can add additional handling here like showing an alert
  }
  
  @objc private func screenCaptureChanged() {
    if #available(iOS 11.0, *) {
      if UIScreen.main.isCaptured {
        print("⚠️ Screen recording detected!")
        // You can add additional handling here
      }
    }
  }
}
