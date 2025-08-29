@echo off
echo 🚀 Netflix Backend Setup Script
echo ================================

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js v16 or higher first.
    echo Visit: https://nodejs.org/
    pause
    exit /b 1
)

REM Check Node.js version
for /f "tokens=1,2 delims=." %%a in ('node --version') do set NODE_VERSION=%%a
set NODE_VERSION=%NODE_VERSION:~1%
if %NODE_VERSION% lss 16 (
    echo ❌ Node.js version 16 or higher is required. Current version: 
    node --version
    pause
    exit /b 1
)

echo ✅ Node.js version: 
node --version

REM Check if npm is installed
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not installed. Please install npm first.
    pause
    exit /b 1
)

echo ✅ npm version: 
npm --version

REM Install dependencies
echo 📦 Installing dependencies...
npm install

if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully

REM Create .env file if it doesn't exist
if not exist .env (
    echo 🔧 Creating .env file...
    copy env.example .env
    echo ✅ .env file created from template
    echo ⚠️  Please edit .env file with your configuration:
    echo    - Set your TMDB API key
    echo    - Configure MongoDB connection string
    echo    - Set JWT secret
) else (
    echo ✅ .env file already exists
)

echo.
echo 🎉 Setup completed successfully!
echo.
echo Next steps:
echo 1. Edit .env file with your configuration
echo 2. Start the server: npm run dev
echo 3. Test the API: http://localhost:3000/health
echo.
echo 📚 For more information, see README.md
echo.
echo Happy coding! 🎬✨
pause
