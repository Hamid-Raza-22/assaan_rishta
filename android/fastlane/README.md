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

### android build_apk_split

```sh
[bundle exec] fastlane android build_apk_split
```

Build APK with split per ABI

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

### android production

```sh
[bundle exec] fastlane android production
```

Deploy to Play Store Production

### android production_with_notes

```sh
[bundle exec] fastlane android production_with_notes
```

Deploy to Production with Release Notes (Urdu + English)

### android promote_internal_to_alpha

```sh
[bundle exec] fastlane android promote_internal_to_alpha
```

Promote from Internal to Alpha

### android promote_alpha_to_beta

```sh
[bundle exec] fastlane android promote_alpha_to_beta
```

Promote from Alpha to Beta

### android promote_beta_to_production

```sh
[bundle exec] fastlane android promote_beta_to_production
```

Promote from Beta to Production

### android test

```sh
[bundle exec] fastlane android test
```

Run Flutter tests

### android analyze

```sh
[bundle exec] fastlane android analyze
```

Run Flutter analyze

### android clean

```sh
[bundle exec] fastlane android clean
```

Clean Flutter project

### android doctor

```sh
[bundle exec] fastlane android doctor
```

Check Flutter doctor

### android deploy_full

```sh
[bundle exec] fastlane android deploy_full
```

Build and deploy to Production (Complete workflow)

### android upload_metadata

```sh
[bundle exec] fastlane android upload_metadata
```

Upload metadata to Play Store

### android upload_screenshots

```sh
[bundle exec] fastlane android upload_screenshots
```

Upload screenshots only

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
