# iOS Notification Fix Guide

## ✅ What Was Fixed

### 1. **AppDelegate.swift Updated**
- Added Firebase initialization
- Configured APNs token registration
- Implemented notification delegates for foreground/background handling
- Added FCM token refresh handling

### 2. **Info.plist Verified**
- ✅ `UIBackgroundModes` includes `remote-notification`
- ✅ All required permissions configured

---

## 🔧 Manual Configuration Required

### **Step 1: Install CocoaPods Dependencies**

Due to Ruby 3.4 encoding issue, run with proper locale:

```bash
cd ios
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
pod install
```

If you still get encoding errors, try:
```bash
# Option 1: Use bundle
bundle exec pod install

# Option 2: Downgrade Ruby (if possible)
rbenv install 3.3.0
rbenv local 3.3.0
pod install
```

---

### **Step 2: Configure Xcode Capabilities**

1. **Open Workspace** (Important!)
   ```bash
   cd ios
   open Runner.xcworkspace  # NOT Runner.xcodeproj
   ```

2. **Select Runner Target**
   - In left sidebar, click on blue **Runner** project
   - Select **Runner** under TARGETS (not PROJECTS)

3. **Add Push Notifications Capability**
   - Go to **Signing & Capabilities** tab
   - Click **+ Capability** button
   - Search for and add **"Push Notifications"**
   - This creates `Runner.entitlements` file automatically

4. **Verify Background Modes**
   - Ensure **Background Modes** capability exists
   - Check these boxes:
     - ✅ **Remote notifications**
     - ✅ **Background fetch** (optional)

5. **Check Signing**
   - Ensure **Automatically manage signing** is checked
   - Or configure manual provisioning profile with Push Notifications enabled

---

### **Step 3: Configure APNs in Firebase**

#### **A. Get APNs Authentication Key (Recommended)**

1. **Generate APNs Key in Apple Developer**
   - Go to: https://developer.apple.com/account/resources/authkeys/list
   - Click **+** to create new key
   - Name: "Firebase Cloud Messaging"
   - Enable: **Apple Push Notifications service (APNs)**
   - Click **Continue** → **Register** → **Download**
   - ⚠️ Save the `.p8` file securely (can't re-download)
   - Note your **Key ID** and **Team ID**

2. **Upload to Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select project: **asaan-rishta-chat**
   - Go to: **Project Settings** (⚙️ icon) → **Cloud Messaging** tab
   - Under **Apple app configuration**:
     - Click **Upload** in APNs Authentication Key section
     - Upload your `.p8` file
     - Enter your **Key ID** and **Team ID**

#### **B. OR Use APNs Certificate (Legacy)**

If you prefer certificates over keys:

1. **Generate Certificate Signing Request (CSR)**
   - Open **Keychain Access** on Mac
   - Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate**
   - Enter your email and name
   - Choose **"Saved to disk"**
   - Save the `.certSigningRequest` file

2. **Create APNs Certificate**
   - Go to: https://developer.apple.com/account/resources/identifiers/list
   - Find your app's Bundle ID: `com.asan.rishta.matrimonial.asanRishta`
   - Click **Edit** → Scroll to **Push Notifications**
   - Click **Configure** for Development or Production
   - Upload the CSR file
   - Download the certificate (`.cer`)

3. **Convert Certificate to .p12**
   - Double-click the `.cer` file (adds to Keychain)
   - Open **Keychain Access** → **My Certificates**
   - Find the "Apple Push Services" certificate
   - Right-click → **Export**
   - Choose format: **Personal Information Exchange (.p12)**
   - Set a password
   - Save the file

4. **Upload to Firebase**
   - Firebase Console → **Cloud Messaging** → **Apple app configuration**
   - Upload the `.p12` file
   - Enter the password

---

### **Step 4: Test Notification Setup**

#### **A. Check Device Token Generation**

Run the app and check Xcode console logs:

```
✅ iOS Notification permission granted
✅ APNs device token registered
🔑 Firebase FCM token: [YOUR_TOKEN]
```

If you see errors:
- ❌ `No valid "aps-environment" entitlement` → Rebuild after adding capability
- ❌ `Permission denied` → User must allow notifications in device Settings
- ❌ `Invalid provisioning profile` → Update provisioning with Push enabled

#### **B. Send Test Notification**

1. **From Firebase Console**
   - Go to **Engage** → **Messaging**
   - Click **Create your first campaign** or **New campaign**
   - Choose **Firebase Notification messages**
   - Enter title and message
   - Click **Send test message**
   - Enter your FCM token from app logs
   - Click **Test**

2. **Test Different States**
   - ✅ App in foreground (should show notification)
   - ✅ App in background (should show in notification center)
   - ✅ App terminated (should wake app when tapped)

---

### **Step 5: Clean Build & Run**

```bash
# Clean everything
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd /Users/apple/Documents/FlutterDev/projects/assaan_rishta_new

# Rebuild (find your Flutter path first)
# Check with: which flutter
# Or common locations: ~/flutter/bin/flutter or /usr/local/bin/flutter

flutter clean
flutter pub get

# Build for iOS
cd ios
pod install
cd ..

# Run on device (NOT simulator for push notifications)
flutter run --release -d [YOUR_DEVICE_ID]

# To list devices:
flutter devices
```

---

## 🐛 Troubleshooting

### **Issue: Notifications not received**

**Check:**
1. ✅ Device has notification permission (Settings → Asaan Rishta → Notifications)
2. ✅ APNs key/certificate uploaded to Firebase
3. ✅ Using **physical device** (simulators don't support real push)
4. ✅ Running in **Release mode** (Debug may have issues)
5. ✅ App has valid FCM token (check logs)
6. ✅ APNs environment matches (Development vs Production)

**Solutions:**
```bash
# Delete app from device
# Clean build folders
rm -rf ios/Pods ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstall
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run --release
```

---

### **Issue: "No valid aps-environment entitlement"**

**Cause:** Push Notifications capability not added in Xcode

**Fix:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add Push Notifications capability (see Step 2)
3. Clean and rebuild

---

### **Issue: CocoaPods encoding error**

**Fix:**
```bash
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
cd ios
pod install
```

Or add to `~/.zshrc`:
```bash
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
```

---

### **Issue: APNs token not uploaded to FCM**

**Check AppDelegate logs:**
```
✅ APNs device token registered
```

If missing, verify:
- Correct provisioning profile
- Push Notifications capability enabled
- Running on physical device

---

### **Issue: Firebase token empty**

**Possible causes:**
1. Firebase not initialized properly
2. GoogleService-Info.plist missing/incorrect
3. Network connection issue

**Fix:**
1. Verify `GoogleService-Info.plist` exists in `ios/Runner/`
2. Check Bundle ID matches: `com.asan.rishta.matrimonial.asanRishta`
3. Ensure internet connection

---

## 📱 Testing Checklist

- [ ] Run `pod install` successfully
- [ ] Open `Runner.xcworkspace` in Xcode
- [ ] Add **Push Notifications** capability
- [ ] Upload APNs key/certificate to Firebase
- [ ] Clean build
- [ ] Install on **physical device** (not simulator)
- [ ] Allow notification permissions
- [ ] Check logs for FCM token
- [ ] Send test notification from Firebase Console
- [ ] Test foreground notification
- [ ] Test background notification
- [ ] Test app launch from notification

---

## 🎯 Expected Behavior After Fix

1. **App Launch:**
   - Requests notification permission
   - Registers with APNs
   - Gets FCM token
   - Uploads token to Firestore

2. **Foreground Notification:**
   - Shows banner at top
   - Plays sound
   - Updates badge

3. **Background Notification:**
   - Shows in notification center
   - Tapping opens chat with sender

4. **Terminated State:**
   - Notification wakes app
   - Opens directly to chat

---

## 📝 Additional Resources

- [Firebase iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [APNs Configuration](https://developer.apple.com/documentation/usernotifications)
- [Flutter FCM Plugin](https://pub.dev/packages/firebase_messaging)

---

## 🆘 Still Having Issues?

1. Check Xcode console for error messages
2. Verify all steps completed in order
3. Ensure using **Release build** on **physical device**
4. Check Firebase Console → Cloud Messaging for errors
5. Verify APNs certificate/key is valid and not expired
