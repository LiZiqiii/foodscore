# FoodScore
FoodScore is an Android app that uses GPT to give meal-quality feedback from a photo or a short text description.

Author: Ziqi Li  
Date: 6 September 2026

## What it does
- Sign up / log in / reset password
- Upload a meal photo, or describe the meal in text
- Results are split across three pages: Score, Insight, and Tips
- Optional Coaching Profile (age, height/weight, health-related preferences) — used to tune the wording, not the score
- Weekly Reflection: review meals saved over the last few days, plus a weekly summary

App entry: `lib/main.dart` (opens on the login screen)  
Backend entry: `backend/main.py`

## Requirements
To use the app (hosted backend, default):
- Flutter SDK (`pubspec.yaml` currently requires Dart `^3.12.2`)
- An Android phone (USB debugging) or an Android emulator
- Internet access
You do not need Python, an OpenAI API key, or any config changes.
The app already points at the hosted backend (`localApiBaseUrl` in `lib/config/app_config.dart`).

## How to run
Unzip the project and open the app folder:
```bash
cd flutter_application_exercise
flutter pub get
```
Then pick one of the two options below. After the app opens, create an account (Sign up), then log in.

### Option A — run on a phone or emulator
Plug in a phone with USB debugging, or start an Android emulator, then:
```bash
flutter run
```

### Option B — install an APK on a phone
```bash
flutter build apk --release
```
The APK is `build/app/outputs/flutter-apk/app-release.apk`. Copy it to the phone and install it.
### Local backend (optional)
Only if you want to run the API on your own machine instead of the hosted backend.
You will need Python 3, `backend/requirements.txt`, and an OpenAI API key in `backend/.env` (do not commit that file).
```bash
cd flutter_application_exercise/backend
python -m venv .venv
# Windows: .venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
# put OPENAI_API_KEY in .env
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Set `localApiBaseUrl` in `lib/config/app_config.dart`.
Use `http://127.0.0.1:8000` on a computer, or `http://10.0.2.2:8000` on the Android emulator.
A physical phone cannot use `127.0.0.1`.