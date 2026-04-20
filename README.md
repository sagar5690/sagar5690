# KnockDesk (macOS)

A **simple and privacy-first macOS menu bar app** that listens for a desk knock pattern and triggers safe automations.

> Goal: mimic a lightweight “knock to trigger action” experience inspired by the idea behind Knock, but designed for modern macOS with explicit privacy controls.

## What it does

- Runs in the menu bar.
- Uses the Mac microphone only when detection is enabled.
- Detects a very simple knock pattern (two peaks close together).
- Triggers one configured action:
  - Play/Pause media (`F8` media key event)
  - Switch to next app (Cmd+Tab simulation)
  - Sleep Mac (AppleScript)
  - Open YouTube in Chrome (or default browser fallback)
  - Launch a specific app by bundle identifier

## Privacy and safety principles

- **No network calls** in the app.
- **No audio recording to disk**.
- Audio is reduced to amplitude values in memory only.
- Microphone use can be enabled/disabled from UI.
- Action execution is explicit and user-selected.

## Important platform constraints

- MacBooks do **not** expose a standard public accelerometer API like iPhone for this use case; the safest cross-Mac approach is microphone-based knock detection.
- Some actions (like synthetic key events or app switching) may require Accessibility permissions in **System Settings → Privacy & Security → Accessibility**.

## Build (on macOS)

```bash
swift build -c release
```

## Run (on macOS)

```bash
swift run KnockDesk
```

## Create app bundle and DMG (on macOS)

```bash
bash scripts/build_dmg.sh
```

This script creates:

- `dist/KnockDesk.app`
- `dist/KnockDesk.dmg`

## App Store / distribution notes

If you plan App Store distribution, review Apple’s App Review and privacy requirements and provide clear user consent prompts for microphone and input monitoring/accessibility related behavior.
