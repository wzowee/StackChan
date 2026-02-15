# StackChan Emulator Quick Reference

Quick reference for common tasks when working with the M5Stack LVGL Emulator.

## Prerequisites Check

Before starting, verify you have:
- [ ] SDL2 installed (`sdl2-config --version` should work)
- [ ] VS Code installed (`code --version` should work)
- [ ] PlatformIO extension installed in VS Code
- [ ] Emulator repository cloned

## Common Commands

### Build Only
```bash
cd ~/lv_m5_emulator
pio run
```

### Build and Run
```bash
cd ~/lv_m5_emulator
pio run -t upload
```

### Clean Build
```bash
cd ~/lv_m5_emulator
pio run -t clean
pio run
```

### Open in VS Code
```bash
code ~/lv_m5_emulator
```

## Emulator Keyboard Controls

| Key | Action |
|-----|--------|
| 1-6 | Zoom levels |
| L | Rotate left |
| R | Rotate right |
| Mouse | Touch interaction |
| ESC | Close emulator |

## File Locations

### Emulator Project Structure
```
~/lv_m5_emulator/
├── platformio.ini       # PlatformIO configuration
├── src/
│   └── main.cpp        # Your emulator entry point
├── lib/                # Libraries
└── include/            # Headers
```

### StackChan Source Files
```
~/StackChan/firmware/main/
├── stackchan/
│   └── avatar/         # Avatar UI components
├── assets/             # Images, fonts, etc.
└── apps/               # Application screens
```

## Quick Integration Steps

### 1. Copy StackChan Components
```bash
# From StackChan root directory
cp -r firmware/main/stackchan/avatar ~/lv_m5_emulator/src/
cp -r firmware/main/assets ~/lv_m5_emulator/src/
```

### 2. Update Include Paths
In your emulator's `src/main.cpp`:
```cpp
#include "avatar/avatar.h"
#include "assets/assets.h"
```

### 3. Build and Test
```bash
cd ~/lv_m5_emulator
pio run -t upload
```

## Common Issues and Fixes

### Issue: SDL2 not found

**Linux:**
```bash
sudo apt-get install libsdl2-dev
```

**macOS:**
```bash
brew install sdl2 pkg-config
```

### Issue: Build fails with "out of memory"

Edit `lv_conf.h`:
```c
#define LV_MEM_SIZE (128 * 1024U)
```

### Issue: Emulator window doesn't appear

1. Check build output for errors
2. Verify SDL2 is installed: `sdl2-config --version`
3. Try running directly: `pio run -t upload -v` (verbose)

### Issue: Touch not working

Make sure M5GFX touch configuration matches your emulator setup in `src/main.cpp`.

## Performance Optimization

### For Faster Builds
Add to `platformio.ini`:
```ini
build_flags =
    -O2
    -D LV_CONF_INCLUDE_SIMPLE
```

### For Smoother Animation
In `lv_conf.h`:
```c
#define LV_DISP_DEF_REFR_PERIOD 5    // 5ms = ~200 FPS
#define LV_USE_PERF_MONITOR 1        // Show FPS counter
```

## Development Workflow

### Typical Development Cycle

1. **Edit** StackChan UI code in your editor
2. **Copy/Sync** to emulator project (if using copy method)
3. **Build** with `pio run`
4. **Test** in emulator window
5. **Iterate** - go back to step 1
6. **Flash** to hardware when satisfied

### Using Symlinks (Advanced)

Instead of copying files, use symlinks for automatic sync:

```bash
cd ~/lv_m5_emulator/src
ln -s ~/StackChan/firmware/main/stackchan/avatar ./avatar
ln -s ~/StackChan/firmware/main/assets ./assets
```

Changes in StackChan will automatically appear in emulator.

## Testing Checklist

Before flashing to hardware, test these in the emulator:

- [ ] All UI elements display correctly
- [ ] Touch/click interactions work
- [ ] Animations are smooth
- [ ] No memory leaks (check with long run)
- [ ] Different screen orientations (if applicable)
- [ ] Edge cases (long text, missing data, etc.)

## Debugging Tips

### Enable LVGL Logging
In `lv_conf.h`:
```c
#define LV_USE_LOG 1
#define LV_LOG_LEVEL LV_LOG_LEVEL_TRACE
```

### Print Debug Info
```cpp
LV_LOG_USER("Debug: value = %d", my_value);
```

### Memory Usage
```cpp
lv_mem_monitor_t mon;
lv_mem_monitor(&mon);
printf("Memory used: %d%%\n", mon.used_pct);
```

## Useful PlatformIO Commands

```bash
# List available targets
pio run --list-targets

# Verbose build (show all commands)
pio run -v

# Monitor serial output (if applicable)
pio device monitor

# Update libraries
pio lib update

# Clean everything
pio run -t clean
rm -rf .pio
```

## Additional Resources

- [Full Setup Guide](EMULATOR_SETUP.md)
- [Example main.cpp](emulator_example_main.cpp)
- [LVGL Documentation](https://docs.lvgl.io/)
- [M5GFX Documentation](https://github.com/m5stack/M5GFX)
- [PlatformIO CLI Reference](https://docs.platformio.org/en/latest/core/userguide/index.html)

## Tips and Tricks

### Fast Iteration
Keep VS Code open with emulator project. Use Ctrl+Alt+B (build) and Ctrl+Alt+U (upload and run) for quick iteration.

### Multiple Monitors
Run emulator on one screen, edit code on another for efficient development.

### Version Control
Keep emulator configuration in a separate branch or ignore emulator-specific files:
```bash
# In StackChan/.gitignore
emulator/
.emulator_config
```

### Sharing Configurations
If working with a team, commit a sample `emulator_config_template.ini` that others can copy and customize.

---

For issues or questions, refer to the [main setup documentation](EMULATOR_SETUP.md) or check the [emulator repository issues](https://github.com/m5stack/lv_m5_emulator/issues).
