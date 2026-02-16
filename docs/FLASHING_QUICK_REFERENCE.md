# StackChan Flashing Quick Reference

Quick reference for flashing StackChan firmware to CoreS3/CoreS3 SE.

## Prerequisites

- [ ] Python 3.8+ installed
- [ ] Python virtual environment created and activated
- [ ] ESP-IDF v5.5.1 installed
- [ ] CoreS3/CoreS3 SE connected via USB-C
- [ ] USB drivers installed
- [ ] ESP-IDF environment activated

## Quick Commands

### First Time Setup

#### 1. Create Python Virtual Environment (Recommended)

```bash
# Linux/macOS
mkdir -p ~/stackchan-dev
cd ~/stackchan-dev
python3 -m venv venv
source venv/bin/activate

# Windows
mkdir %USERPROFILE%\stackchan-dev
cd %USERPROFILE%\stackchan-dev
python -m venv venv
venv\Scripts\activate
```

Add to `~/.bashrc` or `~/.zshrc` for easy access:
```bash
alias stackchan-env='source ~/stackchan-dev/venv/bin/activate'
```

#### 2. Install ESP-IDF

```bash
# Linux/macOS (with venv active!)
mkdir -p ~/esp && cd ~/esp
git clone -b v5.5.1 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
./install.sh esp32s3

# Create combined alias for venv + ESP-IDF
alias get_idf='source ~/stackchan-dev/venv/bin/activate && . ~/esp/esp-idf/export.sh'
```

### Starting a Session

```bash
# Linux/macOS - Activate venv and ESP-IDF
source ~/stackchan-dev/venv/bin/activate
. ~/esp/esp-idf/export.sh

# Or use alias (if configured)
get_idf

# Windows
%USERPROFILE%\stackchan-dev\venv\Scripts\activate
C:\Espressif\esp-idf\export.bat

# Verify activation (should show venv paths)
which python3  # Linux/macOS
where python   # Windows
```

### Build and Flash

```bash
# Navigate to firmware directory
cd /path/to/StackChan/firmware

# Fetch dependencies (first time only)
python3 ./fetch_repos.py

# Build firmware
idf.py build

# Flash to device
idf.py flash

# Flash and monitor
idf.py flash monitor
```

### Using Helper Scripts

```bash
# Interactive menu-driven flash helper
./scripts/flash_stackchan.sh        # Linux/macOS
scripts\flash_stackchan.bat         # Windows
```

## Common Commands

| Command | Description |
|---------|-------------|
| `idf.py build` | Build firmware only |
| `idf.py flash` | Flash to device |
| `idf.py monitor` | Monitor serial output |
| `idf.py flash monitor` | Flash and monitor |
| `idf.py app-flash` | Flash app only (faster) |
| `idf.py clean` | Clean build files |
| `idf.py fullclean` | Full clean (including dependencies) |
| `idf.py erase-flash` | Erase entire flash |
| `idf.py menuconfig` | Configure build options |

## Port Selection

### Auto-detect (recommended)
```bash
idf.py flash
```

### Manual port
```bash
idf.py -p /dev/ttyUSB0 flash        # Linux
idf.py -p /dev/cu.usbserial-* flash # macOS
idf.py -p COM3 flash                # Windows
```

### Find your port

**Linux:**
```bash
ls /dev/ttyUSB* /dev/ttyACM*
```

**macOS:**
```bash
ls /dev/cu.*
```

**Windows:**
- Check Device Manager → Ports (COM & LPT)
- Usually COM3, COM4, etc.

## Build Speeds

| Command | Time (first build) | Time (rebuild) |
|---------|-------------------|----------------|
| `idf.py build` | 5-15 minutes | 30-60 seconds |
| `idf.py app-flash` | - | 10-20 seconds |

## Troubleshooting Quick Fixes

### Virtual Environment Issues

#### "No module named 'esptool'" or similar
```bash
# Make sure virtual environment is activated
source ~/stackchan-dev/venv/bin/activate  # Linux/macOS
# You should see (venv) in your prompt

# Verify Python is from venv
which python3  # Should show venv path

# If wrong Python, deactivate and reactivate
deactivate
source ~/stackchan-dev/venv/bin/activate
```

#### Python packages conflict
```bash
# Deactivate any active environment
deactivate

# Remove and recreate virtual environment
rm -rf ~/stackchan-dev/venv
cd ~/stackchan-dev
python3 -m venv venv
source venv/bin/activate

# Reinstall ESP-IDF tools
cd ~/esp/esp-idf
./install.sh esp32s3
```

### "Failed to connect"
```bash
# Try slower baud rate
idf.py -b 115200 flash

# Or hold RESET button while flashing
```

### "Component not found"
```bash
# Re-fetch dependencies
cd firmware
python3 ./fetch_repos.py
```

### "Permission denied" (Linux)
```bash
# Add user to dialout group
sudo usermod -a -G dialout $USER
# Log out and back in
```

### "ESP-IDF not found"
```bash
# Activate virtual environment first, then ESP-IDF
source ~/stackchan-dev/venv/bin/activate
. ~/esp/esp-idf/export.sh

# Or use combined alias
get_idf
```

### Build fails
```bash
# Clean and rebuild
idf.py fullclean
idf.py build
```

### Device not detected
- Check USB cable (must support data, not charge-only)
- Try different USB port
- Restart CoreS3 device
- Check drivers installed

## Development Workflow

### Standard Workflow
```bash
# 1. Edit code
vim firmware/main/apps/app_avatar/app_avatar.cpp

# 2. Build
cd firmware && idf.py build

# 3. Flash
idf.py flash monitor

# 4. Test and iterate
```

### Fast Iteration (app-only flash)
```bash
# After editing app code (no bootloader/partition changes)
idf.py app-flash monitor
# This is much faster than full flash
```

### With Emulator (recommended)
```bash
# 1. Develop and test in emulator (fast)
# See: docs/EMULATOR_SETUP.md

# 2. Build for hardware
cd firmware && idf.py build

# 3. Flash to device (less frequent)
idf.py flash monitor
```

## Serial Monitor

### Start monitor
```bash
idf.py monitor
# Press Ctrl+] to exit
```

### Monitor with filters
```bash
# Filter by log level
idf.py monitor --print-filter="*:I"  # Info and above
idf.py monitor --print-filter="*:V"  # Verbose (all)
idf.py monitor --print-filter="app*:V"  # Verbose for app tags only
```

### Common monitor shortcuts
| Key | Action |
|-----|--------|
| `Ctrl+]` | Exit monitor |
| `Ctrl+T` `Ctrl+R` | Reset device |
| `Ctrl+T` `Ctrl+H` | Show help |

## Partition Management

### View partitions
```bash
idf.py partition-table
```

### Flash specific partition
```bash
# Flash bootloader only
idf.py bootloader-flash

# Flash app only
idf.py app-flash
```

## Advanced Options

### Optimize build speed
```bash
# Use multiple CPU cores
idf.py -j8 build
```

### Different optimization levels
```bash
# Configure optimization
idf.py menuconfig
# Component config → Compiler options → Optimization Level
```

### Custom baud rates
```bash
# Flash at specific baud rate
idf.py -b 115200 flash   # Slower, more reliable
idf.py -b 921600 flash   # Faster (default)
```

## Backup and Restore

### Backup current flash
```bash
esptool.py -p /dev/ttyUSB0 read_flash 0 0x1000000 backup.bin
```

### Restore from backup
```bash
esptool.py -p /dev/ttyUSB0 write_flash 0 backup.bin
```

## First Boot Checks

After flashing, verify:
- [ ] Serial monitor shows clean boot (no crashes)
- [ ] Display shows StackChan UI
- [ ] No error messages in log
- [ ] WiFi configuration accessible
- [ ] Touch screen responsive
- [ ] Servos respond to commands

## File Locations

| Path | Description |
|------|-------------|
| `firmware/main/main.cpp` | Main entry point |
| `firmware/main/apps/` | Application code |
| `firmware/main/stackchan/` | StackChan core components |
| `firmware/sdkconfig.defaults` | Default configuration |
| `firmware/build/` | Build output (generated) |

## Environment Variables

```bash
# Useful ESP-IDF variables
export IDF_CCACHE_ENABLE=1          # Enable ccache for faster builds
export IDF_TARGET=esp32s3           # Set target chip
export IDF_TOOLS_PATH=~/esp         # ESP tools location
```

## Log Levels

Configure in `idf.py menuconfig` or code:

```c
ESP_LOGE(TAG, "Error");     // Red - Errors
ESP_LOGW(TAG, "Warning");   // Yellow - Warnings
ESP_LOGI(TAG, "Info");      // Green - Info
ESP_LOGD(TAG, "Debug");     // White - Debug
ESP_LOGV(TAG, "Verbose");   // Gray - Verbose
```

## Useful Resources

- [Full Flashing Guide](FLASHING_GUIDE.md)
- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/en/v5.5.1/)
- [Emulator Setup](EMULATOR_SETUP.md)
- [M5Stack CoreS3 Docs](https://docs.m5stack.com/en/core/CoreS3)

## Pro Tips

1. **Use app-flash for faster iteration** - When you're only changing application code, use `idf.py app-flash` instead of `idf.py flash`

2. **Keep ESP-IDF terminal ready** - Create a terminal profile that auto-runs `. ~/esp/esp-idf/export.sh`

3. **Enable ccache** - Add `export IDF_CCACHE_ENABLE=1` to your shell profile for faster rebuilds

4. **Monitor in separate terminal** - Run monitor in one terminal, build in another

5. **Use helper scripts** - The `flash_stackchan.sh` script provides an interactive menu for common tasks

6. **Test in emulator first** - Develop and test UI in the emulator before flashing to hardware

7. **Save successful builds** - Keep a backup of working firmware: `cp build/stackchan.bin backups/working_$(date +%F).bin`

8. **Watch serial during boot** - Always monitor serial output during first boot after changes

## Common Error Codes

| Error | Meaning | Fix |
|-------|---------|-----|
| `0x101` | Out of memory | Reduce memory usage or increase heap |
| `0x103` | Invalid header | Reflash: `idf.py erase-flash flash` |
| `0x105` | Invalid image | Clean rebuild: `idf.py fullclean build` |
| Brownout | Low power | Check power supply, USB cable |
| Guru Meditation | Crash/exception | Check serial log, review recent changes |

---

For detailed information, see the [complete Flashing Guide](FLASHING_GUIDE.md).
