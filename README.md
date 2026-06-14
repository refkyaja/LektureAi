# Lekture AI

A modern, smart note-taking mobile application for students built with Flutter. Replicated from the original Lekture AI React web application.

## Features
- **Dashboard Hub:** Visual statistics for total notes, tags, and words count.
- **Notes & Editor:** Add, edit, tags, character/word count, auto-save (debounced), swipe-to-delete notes.
- **AI Capturing:**
  - *Voice mode:* Live Continuous Speech to Text dictation with custom animated mic waveforms.
  - *Scan mode:* Optical Character Recognition (OCR) scanner from Camera or Photo Library using Google Gemini vision API.
- **Interactive Study Tools:**
  - *Quiz Generator:* Evaluates note content, calls Gemini to compile 5 Multiple Choice Questions with animations, green/red instant feedback, and final score reporting.
  - *Flashcards:* Extracts 8-12 term/definition pairs from a note, supporting a 3D flip card rotation view and swipe/arrow navigation.
- **AI Ask Tutor:** Friendly AI assistant conversation panel (Lekture), supporting prompt context attachment (tagging multiple notes to feed tutor context).
- **Settings & Profile:** Customize grade level, favorite subjects chips, bio details, dark/light theme toggle, and auto-save toggles.

---

## Setup & Running Instructions

### 1. Pre-requisites
- Ensure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install).
- An active device (Android/iOS emulator, or plugged-in physical device).

### 2. Install Dependencies
Run the package getter from the root directory:
```bash
flutter pub get
```

### 3. Configure API Key
Create your local environment file:
1. Copy the `.env.example` file and rename it to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and insert your [Google Gemini API Key](https://aistudio.google.com/):
   ```env
   GEMINI_API_KEY=AIzaSy...yourKey...
   ```

### 4. Run the Project
Compile and run on your preferred device:
```bash
flutter run
```
