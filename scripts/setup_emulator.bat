@echo off
REM StackChan Emulator Setup Script for Windows
REM This script helps set up the M5Stack LVGL Emulator for StackChan development

setlocal enabledelayedexpansion

echo ================================================
echo StackChan Emulator Setup Script (Windows)
echo ================================================
echo.

REM Configuration
set "EMULATOR_REPO=https://github.com/m5stack/lv_m5_emulator.git"
set "EMULATOR_DIR=%USERPROFILE%\lv_m5_emulator"

REM Get StackChan root directory (parent of scripts directory)
set "STACKCHAN_ROOT=%~dp0.."

echo StackChan root: %STACKCHAN_ROOT%
echo Emulator will be installed to: %EMULATOR_DIR%
echo.

REM Check for Git
echo [Step 1/5] Checking for Git...
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in PATH
    echo Please install Git from https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [OK] Git is installed
echo.

REM Check for MSYS2
echo [Step 2/5] Checking for MSYS2...
if exist "C:\msys64\mingw64\bin" (
    echo [OK] MSYS2 found at C:\msys64
    set "MINGW_PATH=C:\msys64\mingw64\bin"
) else (
    echo [WARNING] MSYS2 not found at default location C:\msys64
    echo.
    echo Please install MSYS2 from https://www.msys2.org/
    echo After installation, run these commands in MSYS2 terminal:
    echo   pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-SDL2
    echo.
    echo Then add C:\msys64\mingw64\bin to your PATH environment variable
    pause
    exit /b 1
)

REM Check PATH for MinGW
echo !PATH! | findstr /C:"msys64\mingw64\bin" >nul
if %errorlevel% neq 0 (
    echo [WARNING] MinGW bin directory not found in PATH
    echo You may need to add C:\msys64\mingw64\bin to your PATH
    echo.
)
echo.

REM Check for VS Code
echo [Step 3/5] Checking for Visual Studio Code...
where code >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] VS Code not found in PATH
    echo Please install VS Code from https://code.visualstudio.com/
) else (
    echo [OK] Visual Studio Code is installed
)
echo.

REM Clone emulator repository
echo [Step 4/5] Cloning emulator repository...
if exist "%EMULATOR_DIR%" (
    echo Emulator directory already exists at %EMULATOR_DIR%
    set /p "OVERWRITE=Do you want to remove it and clone fresh? (y/N): "
    if /i "!OVERWRITE!"=="y" (
        echo Removing existing directory...
        rmdir /s /q "%EMULATOR_DIR%"
    ) else (
        echo Using existing emulator directory
        goto configure
    )
)

git clone "%EMULATOR_REPO%" "%EMULATOR_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone emulator repository
    pause
    exit /b 1
)
echo [OK] Emulator repository cloned
echo.

:configure
REM Configure emulator for LVGL v9
echo [Step 5/5] Configuring emulator for LVGL v9...
set "PLATFORMIO_INI=%EMULATOR_DIR%\platformio.ini"

if not exist "%PLATFORMIO_INI%" (
    echo [ERROR] platformio.ini not found!
    pause
    exit /b 1
)

REM Create backup
copy /y "%PLATFORMIO_INI%" "%PLATFORMIO_INI%.backup" >nul

REM Note: Windows doesn't have sed, so we'll provide instructions
echo [INFO] Please manually update platformio.ini to use LVGL v9:
echo   1. Open %PLATFORMIO_INI%
echo   2. Find build_flags section
echo   3. Change LVGL_USE_V8=1 to LVGL_USE_V8=0
echo   4. Change LVGL_USE_V9=0 to LVGL_USE_V9=1
echo.

REM Final instructions
echo ================================================
echo Setup Complete!
echo ================================================
echo.
echo Next steps:
echo.
echo 1. Open the emulator in VS Code:
echo    code "%EMULATOR_DIR%"
echo.
echo 2. Install PlatformIO extension in VS Code
echo.
echo 3. Ensure MinGW is in your PATH (C:\msys64\mingw64\bin)
echo.
echo 4. Manually configure platformio.ini for LVGL v9 (see above)
echo.
echo 5. Copy StackChan UI components to emulator src directory:
echo    xcopy /E /I "%STACKCHAN_ROOT%\firmware\main\stackchan\avatar" "%EMULATOR_DIR%\src\avatar"
echo.
echo 6. Build and run from VS Code's PlatformIO toolbar
echo.
echo 7. For detailed instructions, see:
echo    %STACKCHAN_ROOT%\docs\EMULATOR_SETUP.md
echo.
echo Emulator location: %EMULATOR_DIR%
echo StackChan location: %STACKCHAN_ROOT%
echo.

pause
