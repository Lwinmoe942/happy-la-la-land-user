# App Store (iOS) checklist

Bundle ID: `com.happylalaland.user`  
Display name: HAPPY LA LA LAND

## Before first upload

1. Create the app in [App Store Connect](https://appstoreconnect.apple.com)
2. In Xcode → Runner target → Signing & Capabilities → select your Team
3. Enable capability only if needed later (Push Notifications for remote push; local alerts work without it)
4. Privacy Policy / Terms / Account deletion URLs (same as Play Store Google Sites pages)

## Build on Mac

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

## Listing copy

Use `store/listing_en.txt` and `store/listing_my.txt`.

Loyalty text must say: **10 paid visits → 1 free child visit**.

## Screenshots

Reuse Play Store phone screenshots from `store/play/phone/` where size fits, or capture on an iPhone simulator.
