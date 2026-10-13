# Shorebird Code Push

Shorebird lets this Flutter app receive Dart code patches after a store release has shipped.

## One-time setup

Install the Shorebird CLI from the official docs:

https://docs.shorebird.dev/

Then initialize this existing app from the repository root:

```sh
make shorebird-init
```

This creates `shorebird.yaml`, creates a Shorebird `app_id`, and adds `shorebird.yaml` to the `flutter.assets` section in `pubspec.yaml`. Commit both files after initialization.

Android already has the required internet permission in `android/app/src/main/AndroidManifest.xml`.

## Release flow

Use Shorebird for the next store build. A normal `flutter build appbundle` release will not be patchable later.

```sh
make shorebird-check
make shorebird-doctor
make shorebird-release-android
```

Upload the generated AAB to Play Console after the Shorebird release command completes.

To create the Shorebird release and upload it to Play Console in one command, use:

```sh
make upload-shorebird-android-internal
```

or for production:

```sh
make upload-shorebird-android
```

Do not use `make bundle` or `make bundle-optimized` for a release that you want to patch later. Those targets use plain Flutter builds and do not create a Shorebird release.

## Patch flow

For Dart-only fixes after that release is live:

```sh
make shorebird-patch-android-staging
```

Test the staging patch, then publish to stable:

```sh
make shorebird-patch-android
```

## Patch limits

Shorebird patches are for Dart code changes. Plan a full store release for native Android/iOS code changes, Gradle/Xcode changes, new or removed assets, fonts, app icons, permissions, or dependency changes that require native build changes.

By default, Shorebird downloads a patch in the background when the app launches. The patched code is used on the next app launch.

This project also has `in_app_update` for Play Store version updates. Keep that path for full store releases; Shorebird patches do not change the public app version number.
