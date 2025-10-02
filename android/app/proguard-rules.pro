######################################################
# FLUTTER SPECIFIC RULES
######################################################
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.FlutterActivity
-keep class io.flutter.embedding.android.FlutterFragment
-keep class io.flutter.embedding.android.FlutterView
-keep class androidx.lifecycle.Lifecycle

######################################################
# AGGRESSIVE SHRINKING / OBFUSCATION
######################################################
# Repackage classes to shrink package size
-repackageclasses ''

# Allow R8 to change access modifiers
-allowaccessmodification

# Remove all Log calls
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Custom Views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Parcelable objects
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Reflection + stack traces
-keepattributes Signature,InnerClasses,EnclosingMethod,Exceptions
-keepattributes *Annotation*

######################################################
# FIREBASE RULES
######################################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firebase Messaging service
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService {
    <init>();
}

-keep class * extends com.google.firebase.iid.FirebaseInstanceIdService {
    <init>();
}

######################################################
# GSON / JSON (if using GSON)
######################################################
-keep class com.google.gson.** { *; }
-keep class com.google.gson.annotations.** { *; }

# Keep model classes (replace with your package)
-keep class com.asan.rishta.matrimonial.asan_rishta.model.** { *; }

######################################################
# RETROFIT / OKHTTP / DIO
######################################################
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

-keep class retrofit2.** { *; }
-keep class retrofit2.converter.** { *; }

-keepattributes Signature
-keepattributes Exceptions

######################################################
# DAGGER / HILT (if you use DI)
######################################################
-keep class dagger.** { *; }
-keep class javax.inject.** { *; }
-dontwarn javax.inject.**

######################################################
# PLAY SERVICES / GOOGLE LIBS
######################################################
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

######################################################
# KOTLIN (if you use Kotlin in plugins)
######################################################
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}
-dontwarn kotlin.**

######################################################
# SHARED PREFERENCES & REFLECTION
######################################################
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

######################################################
# OTHER SAFETY NET
######################################################
# Keep your main application & activities
-keep class com.asan.rishta.matrimonial.asan_rishta.MainActivity { *; }
-keep class com.asan.rishta.matrimonial.asan_rishta.** { *; }

# Avoid stripping Service/Receiver declared in manifest
-keep class * extends android.app.Service { *; }
-keep class * extends android.content.BroadcastReceiver { *; }
-keep class * extends android.content.ContentProvider { *; }
-keep class * extends android.app.Application { *; }

######################################################
# GOOGLE PLAY CORE - Split Install Support
######################################################
# These rules handle the missing Play Core classes that Flutter references
# for split APK installations (used for deferred components)

# Option 1: If you're NOT using deferred components, simply ignore these classes
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Option 2: If you ARE using deferred components or want to keep these classes
# (Comment out Option 1 above and uncomment the rules below)
# -keep class com.google.android.play.core.** { *; }
# -keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
# -keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
######################################################
# SDK 36 (Android 15) SPECIFIC RULES - Add these to your existing file
######################################################

# Complete Play Core ignore (since it's deprecated for SDK 36)
-dontwarn com.google.android.play.**
-dontwarn com.google.android.play.core.**

# Android 15 specific compatibility
-dontwarn android.window.**
-dontwarn android.app.ActivityOptions
-dontwarn android.os.StrictMode$VmPolicy$Builder

# Additional optimizations for SDK 36
-optimizationpasses 5
-dontpreverify

# Ignore all warnings to prevent build failures
-ignorewarnings