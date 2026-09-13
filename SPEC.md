# ThirdReel — project spec

Turn an audio file and a cover image into a finished video, fully offline.
Designed by Saviour Najuna. Powered by Thirdsan.

This document is the single source of truth for building the app. It covers
what the app does, how it's architected, what it looks like, and what a build
pipeline needs to produce. A build agent (e.g. Claude Code) should be able to
scaffold the full Flutter project from this file plus the assets in this kit.

---

## 1. What it does

1. User picks an audio file (mp3/wav/m4a) and a cover image (png/jpg).
2. App shows a live preview (cover image + a scrub bar reflecting audio length).
3. User taps **Merge and export**.
4. App runs FFmpeg locally — no server, no upload — and produces an MP4:
   video = the still image, audio = the full track, duration = audio duration.
5. Finished file is saved to the user's device (gallery on Android, a chosen
   folder on Windows) and is immediately shareable.

This replicates, as a real product, the exact ffmpeg workflow used manually
throughout this project's development:

```
ffmpeg -y -loop 1 -framerate 10 -i cover.png -i audio.mp3 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p" \
  -c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 192k -shortest -movflags +faststart \
  output.mp4
```

## 2. Platforms

Android and Windows, from one Flutter codebase. No iOS/macOS in v1 (the
package used supports them if that changes later).

## 3. Architecture

**Fully offline. No backend.** Earlier drafts of this plan assumed a Laravel
API would run the merge server-side, because the old `ffmpeg_kit_flutter`
package was retired (Jan 2025) with no direct successor. That's no longer the
constraint: **`ffmpeg_kit_flutter_new`** is an actively maintained community
continuation that bundles native FFmpeg for Android, iOS, macOS, and Windows
behind one Dart API, with recent security patches confirming it's alive.

```
lib/
  main.dart
  app.dart                     # MaterialApp, theme, routing
  core/
    theme/
      colors.dart               # design tokens, section 5
      typography.dart
    services/
      merge_service.dart        # wraps ffmpeg_kit_flutter_new
      file_service.dart         # pick/save files, platform-specific paths
  features/
    splash/
      splash_screen.dart
    merge/
      merge_screen.dart         # adapts to mobile / desktop layout
      widgets/
        upload_card.dart
        preview_panel.dart
        merge_button.dart
    layout/
      adaptive_layout.dart      # LayoutBuilder: single-column vs two-pane
  widgets/
    branding_footer.dart        # "Designed by Saviour Najuna · Powered by Thirdsan"
```

**Key package**: `ffmpeg_kit_flutter_new` — build against the **LGPL**
variant, not the full-GPL build. LGPL allows dynamic linking without
obligating ThirdReel's own source to be released under GPL; full-GPL adds
codecs this app doesn't need and carries stricter redistribution terms. (Not
legal advice — worth a quick sanity check if that ever changes.)

**Merge call**, conceptually the same command used throughout this project:

```dart
final session = await FFmpegKit.execute(
  '-y -loop 1 -framerate 10 -i "$imagePath" -i "$audioPath" '
  '-vf "scale=1280:720:force_original_aspect_ratio=decrease,'
  'pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p" '
  '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 192k '
  '-shortest -movflags +faststart "$outputPath"'
);
```

## 4. Screens

### Splash
Full-screen `#0B1220` background, centered logo mark (badge backdrop
`#141C2E`), wordmark "ThirdReel" below it, tagline "Turn your audio into a
video, instantly", and the credit line pinned to the bottom:
"Designed by Saviour Najuna · Powered by Thirdsan". Fades into the merge
screen once the app is ready (no real loading work needed — this is local).

### Merge screen — mobile (single column)
Header with app name + settings icon. Two upload cards stacked (Audio track,
Cover image), each showing filename once picked and a check icon. A preview
panel below (play icon over the cover image). Full-width primary button:
"Merge and export", flat gold fill, no gradient.

### Merge screen — desktop (two-pane)
Minimal window chrome. Left rail (fixed ~200px): the two upload cards
(support drag-and-drop via the `desktop_drop` package, not just tap-to-pick)
stacked above the merge button. Right pane: larger preview with a scrub bar
showing playback position against audio duration. Add keyboard shortcuts:
`Cmd/Ctrl+O` open audio, `Cmd/Ctrl+I` open image, `Cmd/Ctrl+Enter` merge.

Both layouts share the same `MergeScreen` widget tree; `AdaptiveLayout` picks
single-column vs two-pane using `LayoutBuilder` on window width (breakpoint:
720px).

## 5. Design tokens

| Token | Value | Use |
|---|---|---|
| `navy` | `#0B1220` | Primary background |
| `navyLight` | `#141C2E` | Card / panel surface |
| `navyBorder` | `#2A3550` | Card hairline border |
| `gold` | `#D4AF37` | Primary accent, buttons, active icons |
| `cream` | `#F5E6C8` | Primary text on navy |
| `muted` | `#8A93A6` | Secondary text, inactive icons |
| `mutedDark` | `#5A6377` | Tertiary text, footer credit |
| `success` | `#5DCAA5` | File-loaded check icon |

No gradients, no drop shadows — flat fills throughout, matching the King &
Priest cover series this app's identity extends. Corner radius: 12–14px for
cards, 22px (on a 100pt grid) for the icon mark itself. Font weights: regular
and medium only — nothing heavier, keeps it feeling calm rather than shouty.

## 6. Distribution (v1)

Direct download from Thirdsan's own site for both platforms — no Play Store
or Microsoft Store submission yet, to avoid review delay and store dev-account
setup blocking launch. Both builds should still be **code-signed**:

- **Android**: signed `.apk`, hosted on your domain. A Play Store `.aab` is
  also built by the CI workflow so it's ready the moment you want to submit.
- **Windows**: signed `.exe`/installer. Without a code-signing cert, Windows
  SmartScreen will warn users on first run — worth budgeting for a cert
  before public launch.

Phase 2: submit to Google Play (needs a one-time $25 developer account) and
Microsoft Store (needs its own dev account + MSIX packaging) once the app has
real usage behind it.

## 7. CI/CD

`.github/workflows/build.yml` (included in this kit) builds both platforms on
every push to `main`: Android APK + AAB, and a zipped Windows release build,
both uploaded as workflow artifacts. Signing steps are stubbed in as comments
for phase 2, once certs exist.

## 8. Assets included in this kit

```
assets/icon/app_icon_master.svg                  # vector source, edit here first
assets/icon/app_icon_1024.png                     # master icon, navy bg baked in
assets/icon/app_icon_512.png                      # store listing size
assets/icon/app_icon.ico                          # Windows, multi-res (16–256px)
assets/icon/app_icon_adaptive_foreground_1024.png # Android 8+ adaptive icon layer
assets/splash/splash_logo_1024.png                # transparent bg, for splash config
```

Use `flutter_launcher_icons` and `flutter_native_splash` rather than
hand-placing per-density files — both packages generate every required size
from these masters at build time. Example `pubspec.yaml` config:

```yaml
flutter_launcher_icons:
  android: true
  windows:
    generate: true
    icon_file: assets/icon/app_icon.ico
  image_path: assets/icon/app_icon_1024.png
  adaptive_icon_background: "#0B1220"
  adaptive_icon_foreground: assets/icon/app_icon_adaptive_foreground_1024.png

flutter_native_splash:
  color: "#0B1220"
  image: assets/splash/splash_logo_1024.png
  android_12:
    image: assets/splash/splash_logo_1024.png
    color: "#0B1220"
```

## 9. Suggested build order

1. `flutter create thirdreel --platforms=android,windows`
2. Drop in `assets/`, wire up `flutter_launcher_icons` + `flutter_native_splash`, run both generators
3. Build the design tokens + theme (section 5)
4. Build `MergeService` around `ffmpeg_kit_flutter_new` (LGPL variant)
5. Build the mobile single-column `MergeScreen`
6. Add `AdaptiveLayout` + the desktop two-pane variant, drag-and-drop
7. Wire the CI workflow, confirm both artifacts build clean
8. Manual test pass: real audio + image, both platforms, check output plays correctly
