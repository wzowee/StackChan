# StackChan Local Emulator Setup Guide

This guide will help you set up the M5Stack LVGL Emulator for local StackChan development, allowing you to test and iterate on UI changes without constantly flashing firmware to your device.

## Overview

The [lv_m5_emulator](https://github.com/m5stack/lv_m5_emulator) enables you to run and test your LVGL-based StackChan UI on your PC. It uses M5GFX to ensure display consistency between your PC and actual hardware, with device shell graphics for realistic visualization.

## Prerequisites

### Required Software

- **Visual Studio Code** - Download from [code.visualstudio.com](https://code.visualstudio.com/)
- **PlatformIO Extension** - Install from VS Code Extensions marketplace
- **SDL2** - Graphics library for rendering (installation instructions below)
- **Git** - For cloning the emulator repository

### System-Specific Dependencies

#### Linux (Ubuntu/Debian)

```bash
# For 64-bit systems
sudo apt-get update
sudo apt-get install libsdl2-dev build-essential git

# For 32-bit systems (if needed)
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install libsdl2-dev:i386 gcc-multilib g++-multilib
```

#### macOS

```bash
# Install Homebrew if you haven't already
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install SDL2 and pkg-config
brew install sdl2 pkg-config
```

#### Windows

1. Install [MSYS2](https://www.msys2.org/)
2. Open MSYS2 terminal and run:
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-SDL2
```
3. Add MinGW-w64 bin directory to your PATH:
   - Default path: `C:\msys64\mingw64\bin`

## Quick Start

### 1. Clone the Emulator Repository

```bash
# Clone to a directory outside of StackChan (e.g., in your home or projects directory)
cd ~/projects  # or wherever you keep your projects
git clone https://github.com/m5stack/lv_m5_emulator.git
cd lv_m5_emulator
```

### 2. Configure for LVGL v9

StackChan uses LVGL v9.3.0, so you need to configure the emulator to use LVGL v9:

1. Open `platformio.ini` in the emulator directory
2. Find the build flags section and update:
   ```ini
   build_flags =
       -D LVGL_USE_V8=0
       -D LVGL_USE_V9=1
   ```
3. Update the LVGL library dependency from the static v8.3.0 to v9:
   ```ini
   lib_deps =
       lvgl/lvgl@^9.3.0
   ```

### 3. Link Your StackChan UI Code

You have two options to integrate your StackChan UI code:

#### Option A: Copy UI Files (Simpler)
Copy relevant UI source files from StackChan to the emulator's `src/` directory:
```bash
# Example: Copy avatar UI components
cp -r ~/StackChan/firmware/main/stackchan/avatar/* ~/projects/lv_m5_emulator/src/
```

#### Option B: Symbolic Links (Advanced)
Create symbolic links to keep files in sync:
```bash
# Create links to StackChan components you want to test
ln -s ~/StackChan/firmware/main/stackchan/avatar ~/projects/lv_m5_emulator/src/avatar
ln -s ~/StackChan/firmware/main/assets ~/projects/lv_m5_emulator/src/assets
```

### 4. Open in VS Code

```bash
code ~/projects/lv_m5_emulator
```

When prompted, install the PlatformIO extension if you haven't already.

### 5. Build and Run

1. Wait for PlatformIO to finish initializing (bottom toolbar will show "PlatformIO: Ready")
2. Click the **Build** button (checkmark icon) in the bottom toolbar, or press `Ctrl+Alt+B`
3. Click the **Upload and Monitor** button (arrow icon) in the bottom toolbar, or press `Ctrl+Alt+U`

The emulator window should appear showing your StackChan UI!

## Emulator Controls

Once the emulator is running, you can interact with it using keyboard shortcuts:

- **Zoom**: Press number keys `1` through `6` to zoom in/out
- **Rotate**: Press `L` to rotate left, `R` to rotate right
- **Mouse**: Click and drag to interact with touch elements

## Performance Tuning

If you experience performance issues or crashes with complex UIs:

### Increase Memory Allocation

Edit `lv_conf.h` (or the configuration file in your emulator setup):

```c
// Increase heap size for LVGL (default is usually too small)
#define LV_MEM_SIZE (128 * 1024U)  // 128KB instead of default 32KB

// Increase buffer lines for smoother rendering
#define LV_BUFFER_LINE 10  // Adjust based on your display size
```

### Increase Stack Size

In `platformio.ini`, add to build flags:

```ini
build_flags =
    -D LV_TASK_STACK_SIZE=8192
```

### Use Standard C Allocator

For greater memory flexibility, configure LVGL to use standard malloc/free:

```c
#define LV_MEM_CUSTOM 1
#define LV_MEM_CUSTOM_INCLUDE <stdlib.h>
#define LV_MEM_CUSTOM_ALLOC malloc
#define LV_MEM_CUSTOM_FREE free
```

## Workflow Tips

### Development Cycle

1. Make changes to your UI code
2. Build and run in emulator (fast iteration)
3. Test and refine
4. Once satisfied, build and flash to actual StackChan hardware

### Testing Different Displays

The emulator supports various M5Stack display configurations. Edit the display configuration in `src/main.cpp` or configuration headers to match your StackChan model:

- CoreS3: 320x240 ILI9341/ILI9342
- Core2: 320x240 ILI9342C
- Other M5Stack devices

### Common Issues

**Issue**: SDL2 not found during build
- **Linux**: Ensure `libsdl2-dev` is installed
- **macOS**: Run `brew install sdl2 pkg-config`
- **Windows**: Check MSYS2 MinGW bin is in your PATH

**Issue**: Emulator window doesn't appear
- Check PlatformIO build output for errors
- Verify SDL2 is properly installed
- Try running from terminal: `pio run -t upload`

**Issue**: Out of memory errors
- Increase `LV_MEM_SIZE` as described in Performance Tuning
- Increase task stack size
- Consider using custom allocator

## Integration with StackChan Development

### Recommended Project Structure

```
~/projects/
├── StackChan/               # Main StackChan repository
│   └── firmware/
│       └── main/
│           ├── stackchan/
│           └── assets/
└── lv_m5_emulator/         # Emulator project
    └── src/
        ├── avatar/         # Symlink or copy of stackchan/avatar
        └── assets/         # Symlink or copy of assets
```

### Version Control

Add the emulator directory to your `.gitignore` if you're keeping it separate from StackChan:

```bash
# In StackChan/.gitignore
../lv_m5_emulator/
```

Or create a separate branch for emulator integration if you want to keep them together.

## Additional Resources

- [lv_m5_emulator GitHub](https://github.com/m5stack/lv_m5_emulator)
- [LVGL Documentation](https://docs.lvgl.io/)
- [M5GFX Documentation](https://github.com/m5stack/M5GFX)
- [PlatformIO Documentation](https://docs.platformio.org/)

## Support

If you encounter issues:

1. Check the [emulator issues](https://github.com/m5stack/lv_m5_emulator/issues) page
2. Review StackChan documentation in the main README
3. Ask in the StackChan community forums

## Next Steps

Once you have the emulator running:

1. Experiment with StackChan's avatar expressions
2. Test UI layouts and animations
3. Develop new features with rapid iteration
4. Flash to hardware for final testing

Happy developing!
