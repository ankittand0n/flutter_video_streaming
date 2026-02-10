@echo off
REM Run Flutter web app with production API
echo Starting Flutter Web with Production API...
echo.
flutter run -d chrome --dart-define=API_BASE_URL=https://admin.namkeentv.com/api --dart-define=STORAGE_BASE_URL=https://storage.googleapis.com/namkeen-tv
