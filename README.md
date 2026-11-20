# HAPPY LA LA LAND — Parent user app

Flutter parent app for Android and iOS.

- Package / Bundle ID: `com.happylalaland.user`
- Version: see `pubspec.yaml`
- Loyalty: **10 paid visits → 1 free child** on the next visit
- Prices: child 25,000 MMK · adult 30,000 MMK
- Pay at the playground (no in-app payments)

## Android (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`  
Signed release uses `android/key.properties` + keystore (not committed).

Store listing notes and screenshots: `store/`

## iOS (App Store)

Requires a Mac with Xcode.

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set your Apple Developer **Team** on the Runner target
3. Confirm Bundle ID `com.happylalaland.user` is registered in App Store Connect
4. Bump version in `pubspec.yaml` if needed, then:

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

Upload the IPA from `build/ios/ipa/` with Transporter or Xcode Organizer.

App Store checklist: `store/APP_STORE.md`

## Run locally

```bash
flutter pub get
flutter run
```

Supabase URL / anon key are set via `--dart-define` or defaults in `lib/core/config.dart`.
