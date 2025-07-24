plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hamid.assaan_rishta"
    compileSdk = 36  // Updated from 36 to 34 (stable version)
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.hamid.assaan_rishta"
        minSdk = 21
        targetSdk = 36  // Updated from 36 to 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core Android and Kotlin dependencies
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.10")

    // Flutter Engine dependencies (ESSENTIAL for fixing unresolved references)
//    implementation("io.flutter:flutter_embedding_debug:1.0.0-4f9d92fbbf951021ca5b2c659e1b95ddd6c1b296")
//    implementation("io.flutter:flutter_embedding_profile:1.0.0-4f9d92fbbf951021ca5b2c659e1b95ddd6c1b1296")
//    implementation("io.flutter:flutter_embedding_release:1.0.0-4f9d92fbbf951021ca5b2c659e1b95ddd6c1b1296")

    // AndroidX dependencies for better compatibility
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.annotation:annotation:1.7.1")

    // Additional dependencies for Window Manager (for your security flags)
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
}