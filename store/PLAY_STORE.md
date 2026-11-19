# HAPPY LA LA LAND — Play Store upload guide

## Already prepared

| Item | Location |
| --- | --- |
| Signed App Bundle | `../HAPPY_LA_LA_LAND_User.aab` or `build/app/outputs/bundle/release/app-release.aab` |
| Package name | `com.happylalaland.user` |
| Version | `1.0.3` (versionCode `4`) |

## In-app update

The app checks Google Play on open (and when resumed). If a newer
version is published, Play shows an **immediate** full-screen update.

Notes:
- Works only for installs from Play Store (not USB/APK sideload)
- Test with Internal testing / Closed testing track
- Each Play upload must bump `version:` in `pubspec.yaml` (name + number)
| Icon / feature graphic | `store/play/` |
| Phone screenshots (4) | `store/play/phone/` |
| Tablet screenshots (4) | `store/play/tablet/` |
| Privacy / Terms / Content / Account deletion HTML | `store/legal/` |
| Google Sites steps | `store/legal/GOOGLE_SITES.md` |
| Listing text | `store/listing_en.txt`, `store/listing_my.txt` |

## ကလေးပါလို့ အဆင်ပြေလား?

အဆင်ပြေပါတယ် — ဒီအက်ပ်က **မိဘအက်ပ်** ဖြစ်လို့:

- Target audience မှာ **18+ / parents** ရွေးပါ
- “Designed for children” / Families child-directed မရွေးပါနှင့်
- ကလေးအမည်/ဓာတ်ပုံ/မွေးနေ့ မစုဆောင်းကြောင်း Data safety မှာ ဖြေပါ
- အက်ပ်ထဲ **ငွေပေးချေမှု မရှိ** → In-app purchases = No

## Google Sites

`store/legal/*.html` ကို Google Sites မှာ Publish လုပ်ပြီး URL ယူပါ။ အဆင်ပြေပါတယ်။

Play Console မှာ အနည်းဆုံး:

- Privacy policy URL → `privacy.html` page
- Account deletion URL → `account-deletion.html` page

## Rebuild

```bat
cd user_app
flutter build appbundle --release
```
