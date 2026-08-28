# Fix Android Build Failure and SDK Inconsistencies

The project is currently failing to build with a mysterious `25.0.2` error, likely due to an outdated Build Tools version being requested or an unsupported `compileSdk` version (`36`). We will also address the JVM warning regarding native access.

## Proposed Changes

### Android Build Configuration

#### [MODIFY] [app/build.gradle.kts](file:///C:/flutterdev/projects/assaan_rishta/android/app/build.gradle.kts)
- Lower `compileSdk` and `targetSdk` to `35` (Android 15 stable).
- Update `ndkVersion` to a stable version (`27.0.12077973`).
- Add the requested `jvmArgs` to the `tasks.withType<JavaCompile>` block to suppress warnings.
- Explicitly set `buildToolsVersion` to a modern version to override any `25.0.2` requests from plugins.

#### [MODIFY] [build.gradle.kts](file:///C:/flutterdev/projects/assaan_rishta/android/build.gradle.kts) (Root)
- Add a `subprojects` block to force a consistent `buildToolsVersion` across all plugins, which should resolve the `25.0.2` error if it originates from a dependency.

### Project Structure

#### [MOVE] MainActivity.kt
- Move `MainActivity.kt` from `android/app/src/main/kotlin/com/hamid/assaan_rishta/` to `android/app/src/main/kotlin/com/asan/rishta/matrimonial/asan_rishta/` to match its package name and the project's namespace.

## Verification Plan

### Automated Tests
- Run `flutter clean` to ensure a fresh state.
- Run `flutter build apk --debug` to verify the build succeeds.

### Manual Verification
- Check the Gradle output for the `WARNING: Use --enable-native-access=ALL-UNNAMED` to ensure it is resolved by the new JVM args.
