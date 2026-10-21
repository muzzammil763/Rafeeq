<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/readme/calligraphy-dark.svg">
    <img src=".github/readme/calligraphy-light.svg" alt="Rafeeq" width="220">
  </picture>

  <h3>Your Islamic Companion</h3>

  <p>
    <strong>Rafeeq</strong> is an open-source Islamic companion app built with Flutter
    to support Muslims in their daily spiritual practice.
  </p>
  <p>
    <a href="https://play.google.com/store/apps/details?id=com.satechdev.rafeeqapp">
      <img src=".github/readme/google-play.svg" alt="Get Rafeeq on Google Play" width="220" height="72">
    </a>
    &nbsp;&nbsp;
    <img src=".github/readme/app-store-coming-soon.svg" alt="Rafeeq on the App Store — coming soon" width="220" height="72">
  </p>
</div>

---

## Features

- **Quran** – Read (including a 16-line mushaf view), search, bookmark and share ayahs, with translations
- **Recitations** – Listen with a choice of reciters and a background mini-player
- **Prayer Times** – Location-based times with notifications and adhan sounds
- **Qibla** – Compass pointing towards the Kaaba
- **Hijri & Ramadan Calendars** – With adjustable Hijri date correction
- **Namaz Guide & Daily Duas** – Step-by-step prayer guide and categorized supplications
- **Asma ul Husna** – The 99 Names of Allah with meanings
- **Ayah Picture Maker** – Turn an ayah into a shareable image
- **English & Urdu** – Full localization with Urdu typography, plus light and dark themes

---

## Tech Stack

- **Framework:** Flutter (Dart ≥ 3.10)
- **State Management:** Riverpod + Hooks
- **Local Storage:** SQLite (sqflite) and Shared Preferences
- **Audio:** just_audio
- **Prayer Times & Location:** adhan, Geolocator
- **Monitoring:** Firebase Analytics and Crashlytics (release builds only)
- **Updates:** Shorebird code push

---

## Getting Started

Rafeeq uses Firebase only for Analytics and Crashlytics. The Firebase config files are not committed, so create your own Firebase project, register the Android app (`com.satechdev.rafeeqapp`, plus `com.satechdev.rafeeqapp.debug` for debug builds) and the iOS app (`com.satechdev.rafeeqapp`), then place the downloaded files here:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Then run the app:

```bash
flutter pub get
flutter run
```

Before opening a pull request, make sure both of these pass:

```bash
flutter analyze
flutter test
```

---

## Website

The landing page at [rafeeq.pages.dev](https://rafeeq.pages.dev) lives in [`website/`](website). It is a static [Astro](https://astro.build) site hosted on Cloudflare Pages.

A small guide character walks visitors through the page as they scroll. Its lines live in [`website/src/data/companion.ts`](website/src/data/companion.ts) and the character itself in [`website/src/components/Companion.astro`](website/src/components/Companion.astro).

```bash
cd website
npm install
npm run dev      # local preview at http://localhost:4321
npm run deploy   # build and publish to Cloudflare Pages (needs `wrangler login`)
```

---

## Contributing

Contributions are welcome. Open an issue to discuss bigger changes first, then send a pull request from a feature branch. The maintainers review every pull request before it is merged.

---

<div align="center">
  <p>Made with ❤️ for the Ummah</p>
</div>
