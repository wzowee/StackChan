@echo off
REM StackChan Firmware Flash Helper Script for Windows
REM Automates the build and flash process for CoreS3/CoreS3 SE

setlocal enabledelayedexpansion

REM Get script directory and StackChan root
set "SCRIPT_DIR=%~dp0"
set "STACKCHAN_ROOT=%SCRIPT_DIR%.."
set "FIRMWARE_DIR=%STACKCHAN_ROOT%\firmware"

echo ================================================
echo StackChan Firmware Flash Helper (Windows)
echo ================================================
echo.

REM Check for Python virtual environment
:check_venv
if defined VIRTUAL_ENV (
    echo [OK] Python virtual environment active: %VIRTUAL_ENV%
) else (
    echo [WARNING] No Python virtual environment detected
    echo.
    echo It's recommended to use a virtual environment for ESP-IDF.
    echo This prevents conflicts with system Python packages.
    echo.
    echo To create and activate a virtual environment:
    echo   mkdir %%USERPROFILE%%\stackchan-dev
    echo   cd %%USERPROFILE%%\stackchan-dev
    echo   python -m venv venv
    echo   venv\Scripts\activate
    echo.
    echo Then reinstall ESP-IDF tools in the virtual environment.
    echo See: %STACKCHAN_ROOT%\docs\FLASHING_GUIDE.md
    echo.
    set /p "continue=Continue without virtual environment? (y/N): "
    if /i not "!continue!"=="y" (
        exit /b 1
    )
)
echo.

REM Check for ESP-IDF
:check_idf
where idf.py >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] ESP-IDF not found!
    echo.
    echo Please install ESP-IDF v5.5.1 or open "ESP-IDF Command Prompt"
    echo.
    echo For installation instructions, see:
    echo   %STACKCHAN_ROOT%\docs\FLASHING_GUIDE.md
    echo.
    pause
    exit /b 1
)

REM Check ESP-IDF version
for /f "tokens=*" %%i in ('idf.py --version 2^>^&1') do set IDF_VERSION=%%i
echo [OK] ESP-IDF found: %IDF_VERSION%
echo.

REM Check dependencies
:check_dependencies
if not exist "%FIRMWARE_DIR%\components\mooncake\" (
    echo [INFO] Dependencies not found. Fetching...
    cd /d "%FIRMWARE_DIR%"
    python fetch_repos.py
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to fetch dependencies
        pause
        exit /b 1
    )
    echo [OK] Dependencies fetched
) else (
    echo [OK] Dependencies already present
)
echo.

REM Main menu
:menu
echo.
echo What would you like to do?
echo.
echo 1) Build and flash firmware
echo 2) Build only
echo 3) Flash only (skip build)
echo 4) Flash and monitor
echo 5) Monitor only
echo 6) Clean build
echo 7) Full clean and rebuild
echo 8) Erase flash
echo 9) Exit
echo.

set /p "choice=Select option [1-9]: "

if "%choice%"=="1" goto build_and_flash
if "%choice%"=="2" goto build_only
if "%choice%"=="3" goto flash_only
if "%choice%"=="4" goto flash_and_monitor
if "%choice%"=="5" goto monitor_only
if "%choice%"=="6" goto clean_build
if "%choice%"=="7" goto full_clean
if "%choice%"=="8" goto erase_flash
if "%choice%"=="9" goto exit_script

echo [ERROR] Invalid option
goto menu

:build_only
echo.
echo Building firmware...
echo This may take 5-15 minutes on first build...
echo.
cd /d "%FIRMWARE_DIR%"
idf.py build
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build failed
    echo.
    echo Common solutions:
    echo 1. Run: idf.py fullclean ^&^& idf.py build
    echo 2. Re-fetch dependencies: python fetch_repos.py
    echo 3. Check ESP-IDF version
    echo.
    pause
    goto menu
)
echo.
echo [OK] Build successful!
pause
goto menu

:build_and_flash
call :build_only
if %errorlevel% equ 0 (
    goto flash_only
)
goto menu

:flash_only
echo.
echo Flashing firmware to CoreS3...
echo.
echo If flash fails, try:
echo   - Hold RESET button while flashing
echo   - Use slower baud: idf.py -b 115200 flash
echo.
cd /d "%FIRMWARE_DIR%"
idf.py flash
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Flash failed
    echo.
    echo Troubleshooting:
    echo 1. Check USB cable connection
    echo 2. Hold RESET button while flashing
    echo 3. Try different USB port
    echo 4. Check Device Manager for COM port
    echo.
    pause
    goto menu
)
echo.
echo [OK] Flash successful!
pause
goto menu

:flash_and_monitor
call :build_only
if %errorlevel% equ 0 (
    echo.
    echo Flashing firmware to CoreS3...
    echo.
    cd /d "%FIRMWARE_DIR%"
    idf.py flash monitor
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Flash failed
        pause
    )
)
goto menu

:monitor_only
echo.
echo Starting serial monitor...
echo Press Ctrl+] to exit
echo.
cd /d "%FIRMWARE_DIR%"
idf.py monitor
goto menu

:clean_build
echo.
echo Cleaning build...
cd /d "%FIRMWARE_DIR%"
idf.py clean
echo [OK] Clean complete
pause
goto build_only

:full_clean
echo.
echo Performing full clean...
cd /d "%FIRMWARE_DIR%"
idf.py fullclean
if exist ".pio" rmdir /s /q ".pio"
if exist "build" rmdir /s /q "build"
echo [OK] Full clean complete
pause
goto build_only

:erase_flash
echo.
echo [WARNING] This will erase all data on the device!
set /p "confirm=Are you sure? Type 'yes' to confirm: "
if /i not "%confirm%"=="yes" (
    echo Cancelled
    pause
    goto menu
)
echo.
echo Erasing flash...
cd /d "%FIRMWARE_DIR%"
idf.py erase-flash
if %errorlevel% neq 0 (
    echo [ERROR] Erase failed
    pause
    goto menu
)
echo [OK] Flash erased
pause
goto menu

:exit_script
echo.
echo Done! Happy hacking with StackChan!
echo.
exit /b 0
