fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android build_apk

```sh
[bundle exec] fastlane android build_apk
```

Build APK for testing

### android build_aab

```sh
[bundle exec] fastlane android build_aab
```

Build AAB (Android App Bundle) for Play Store

### android internal

```sh
[bundle exec] fastlane android internal
```

Deploy to Play Store Internal Testing Track

### android alpha

```sh
[bundle exec] fastlane android alpha
```

Deploy to Play Store Alpha Track

### android beta

```sh
[bundle exec] fastlane android beta
```

Deploy to Play Store Beta Track

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Deploy to Play Store Production

### android deploy_with_notes

```sh
[bundle exec] fastlane android deploy_with_notes
```

Deploy to Production with Release Notes

### android promote_to_production

```sh
[bundle exec] fastlane android promote_to_production
```

Promote from Beta to Production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
