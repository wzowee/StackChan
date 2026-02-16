# Flashing StackChan Firmware to CoreS3/CoreS3 SE

This guide will help you build and flash the StackChan firmware to your M5Stack CoreS3 or CoreS3 SE development board.

## Prerequisites

### Hardware Requirements

- **M5Stack CoreS3** or **CoreS3 SE** development board
- USB-C cable for connection to your computer
- Computer with available USB port

### Software Requirements

- **ESP-IDF v5.5.1** (Espressif IoT Development Framework)
- **Python 3.8 or newer**
- **Git**
- USB-to-serial drivers (usually automatic on modern systems)

### Supported Operating Systems

- Linux (Ubuntu 20.04 or newer recommended)
- macOS (10.15 or newer)
- Windows 10/11

## Installation Guide

### Step 1: Set Up Python Virtual Environment (Recommended)

Using a Python virtual environment isolates ESP-IDF dependencies and prevents conflicts with system Python packages.

#### Linux & macOS

```bash
# Install prerequisites first
# Ubuntu/Debian:
sudo apt-get install git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

# macOS:
brew install cmake ninja dfu-util python3

# Create a virtual environment for StackChan development
mkdir -p ~/stackchan-dev
cd ~/stackchan-dev
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Verify Python is from virtual environment
which python3  # Should show ~/stackchan-dev/venv/bin/python3
```

To activate the virtual environment in future sessions:

```bash
source ~/stackchan-dev/venv/bin/activate
```

**Pro Tip:** Add an alias to your `~/.bashrc` or `~/.zshrc`:

```bash
alias stackchan-env='source ~/stackchan-dev/venv/bin/activate'
```

#### Windows

```cmd
REM Create a virtual environment
mkdir %USERPROFILE%\stackchan-dev
cd %USERPROFILE%\stackchan-dev
python -m venv venv

REM Activate the virtual environment
venv\Scripts\activate

REM Verify Python is from virtual environment
where python
```

To activate in future sessions:

```cmd
%USERPROFILE%\stackchan-dev\venv\Scripts\activate
```

**Note:** The virtual environment must be activated before running ESP-IDF commands. You'll see `(venv)` in your terminal prompt when active.

### Step 2: Install ESP-IDF

ESP-IDF is Espressif's official development framework for ESP32 chips.

**Important:** Make sure your Python virtual environment is activated before proceeding!

#### Linux & macOS

```bash
# Ensure virtual environment is active
source ~/stackchan-dev/venv/bin/activate  # Or use your alias: stackchan-env

# Create directory for ESP-IDF
mkdir -p ~/esp
cd ~/esp

# Clone ESP-IDF v5.5.1
git clone -b v5.5.1 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf

# Install ESP-IDF tools (this installs Python packages in your virtual environment)
./install.sh esp32s3

# Set up environment variables (do this in every terminal session, or add to your shell profile)
. ~/esp/esp-idf/export.sh
```

To make ESP-IDF available in every terminal session, add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias get_idf='source ~/stackchan-dev/venv/bin/activate && . ~/esp/esp-idf/export.sh'
```

Then run `get_idf` whenever you open a new terminal for StackChan development. This will activate both your Python virtual environment and ESP-IDF.

#### Windows

**Option A: Using Windows Installer (Easier)**

1. Activate your virtual environment first:
   ```cmd
   %USERPROFILE%\stackchan-dev\venv\Scripts\activate
   ```

2. Download and run the [ESP-IDF Windows Installer](https://dl.espressif.com/dl/esp-idf/)
3. Select ESP-IDF v5.5.1
4. Choose installation directory (default: `C:\Espressif`)
5. Select "ESP32-S3" in the chip selection
6. **Important:** When asked about Python, select "Use an existing Python installation" and point to your virtual environment Python

The installer creates a desktop shortcut "ESP-IDF Command Prompt". Modify it to activate your virtual environment first.

**Option B: Manual Installation**

```cmd
REM Activate virtual environment
%USERPROFILE%\stackchan-dev\venv\Scripts\activate

REM Create ESP directory
mkdir %USERPROFILE%\esp
cd %USERPROFILE%\esp

REM Clone ESP-IDF
git clone -b v5.5.1 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf

REM Install ESP-IDF tools
install.bat esp32s3

REM Set up environment (do this in every session)
export.bat
```

**Note:** On Windows, you'll need to activate the virtual environment and run `export.bat` each time you open a new command prompt for StackChan development.

### Step 3: Verify ESP-IDF Installation

**Important:** Ensure your virtual environment is activated before running these commands!

```bash
# Check virtual environment is active (should show (venv) in prompt)
# Linux/macOS:
which python3  # Should be in venv directory

# Windows:
where python   # Should be in venv directory

```bash
# Verify ESP-IDF installation
idf.py --version         # Should show version 5.5.1
idf.py --list-targets    # Should show ESP32-S3 support

# Verify Python packages
pip list | grep esptool  # Should show esptool package
```

If you see errors about missing packages, make sure your virtual environment is activated.

### Step 4: Install USB Drivers

#### Linux

Most Linux distributions include the necessary drivers. Add your user to the `dialout` group:

```bash
sudo usermod -a -G dialout $USER
# Log out and back in for this to take effect
```

#### macOS

Drivers are usually built-in. If you have issues, install:

```bash
brew install --cask silicon-labs-vcp-driver
```

#### Windows

Drivers are typically installed automatically. If needed, download from:
- [Silicon Labs CP210x Driver](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)

## Building StackChan Firmware

**Important:** Always activate your virtual environment and ESP-IDF before building!

```bash
# Linux/macOS
source ~/stackchan-dev/venv/bin/activate  # Activate virtual environment
. ~/esp/esp-idf/export.sh                 # Load ESP-IDF

# Or use the alias if you set it up:
get_idf

# Windows
%USERPROFILE%\stackchan-dev\venv\Scripts\activate
C:\Espressif\esp-idf\export.bat
```

You should see `(venv)` in your prompt indicating the virtual environment is active.

### Step 1: Navigate to Firmware Directory

```bash
cd /path/to/StackChan/firmware
```

### Step 2: Fetch Dependencies

StackChan uses several external repositories. Fetch them all:

```bash
python3 ./fetch_repos.py
```

This will clone:
- Mooncake framework
- Smooth UI toolkit
- XiaoZhi ESP32
- Various ESP components

### Step 3: Configure the Build (Optional)

The default configuration is already set for CoreS3. If you want to customize:

```bash
idf.py menuconfig
```

Key configurations (already set in `sdkconfig.defaults`):
- Target: ESP32-S3
- Flash size: 16MB
- Board type: M5Stack StackChan
- LVGL v9 support
- Camera support (GC0308)

### Step 4: Build the Firmware

```bash
idf.py build
```

This will:
- Compile all source files
- Link libraries
- Generate firmware binaries
- Create partition table

Build time: 5-15 minutes on first build (subsequent builds are faster).

**Expected output:**
```
Project build complete. To flash, run this command:
idf.py -p (PORT) flash
```

## Flashing to CoreS3/CoreS3 SE

### Step 1: Connect Your Board

1. Connect CoreS3 to your computer via USB-C cable
2. Power on the device (if not already on)
3. The device should be recognized automatically

### Step 2: Identify the Serial Port

#### Linux

```bash
ls /dev/ttyUSB* /dev/ttyACM*
# Usually /dev/ttyUSB0 or /dev/ttyACM0
```

#### macOS

```bash
ls /dev/cu.*
# Usually /dev/cu.usbserial-* or /dev/cu.SLAB_USBtoUART
```

#### Windows

Check Device Manager under "Ports (COM & LPT)" - usually COM3, COM4, etc.

Or let ESP-IDF auto-detect by omitting the `-p` flag.

### Step 3: Flash the Firmware

```bash
# Auto-detect port (recommended)
idf.py flash

# Or specify port explicitly
idf.py -p /dev/ttyUSB0 flash        # Linux
idf.py -p /dev/cu.usbserial-* flash # macOS
idf.py -p COM3 flash                # Windows
```

The flash process will:
1. Erase necessary flash regions
2. Write bootloader
3. Write partition table
4. Write application firmware
5. Verify the flash

**Expected output:**
```
Connecting.....
Chip is ESP32-S3 (revision v0.1)
Features: WiFi, BLE
Crystal is 40MHz
...
Hash of data verified.
Leaving...
Hard resetting via RTS pin...
```

### Step 4: Monitor Serial Output

To see the device boot and check for errors:

```bash
idf.py monitor

# Or combined flash and monitor:
idf.py flash monitor
```

Press `Ctrl+]` to exit the monitor.

## Quick Commands Reference

```bash
# Full build, flash, and monitor in one command
idf.py build flash monitor

# Clean build (when dependencies change)
idf.py fullclean
idf.py build

# Only build (no flash)
idf.py build

# Only flash (no rebuild)
idf.py flash

# Erase entire flash
idf.py erase-flash

# Show partition information
idf.py partition-table
```

## Troubleshooting

### Issue: "No serial ports found"

**Solutions:**
1. Check USB cable (must be data cable, not charge-only)
2. Try a different USB port
3. Check drivers are installed
4. On Linux: verify you're in the `dialout` group
5. Restart the CoreS3 device

### Issue: "A fatal error occurred: Failed to connect"

**Solutions:**
1. Hold the RESET button while running `idf.py flash`
2. Try a slower baud rate: `idf.py -b 115200 flash`
3. Check USB cable quality
4. Try different USB port (avoid USB hubs)

### Issue: "Hash of data verified" but device doesn't boot

**Solutions:**
1. Erase flash completely: `idf.py erase-flash`
2. Reflash: `idf.py flash`
3. Check power supply is adequate
4. Monitor serial output: `idf.py monitor`

### Issue: Build fails with "component not found"

**Solutions:**
1. Ensure you ran `python3 ./fetch_repos.py`
2. Check internet connection
3. Try re-running: `python3 ./fetch_repos.py`
4. Verify ESP-IDF version: `idf.py --version` (should be 5.5.1)

### Issue: "CMake Error" or dependency issues

**Solutions:**
```bash
# Clean everything and rebuild
idf.py fullclean
python3 ./fetch_repos.py
idf.py build
```

### Issue: Permission denied on Linux

```bash
# Add user to dialout group
sudo usermod -a -G dialout $USER

# Or use sudo (not recommended)
sudo idf.py flash
```

### Issue: ESP-IDF not found

Make sure you've sourced the export script:
```bash
. ~/esp/esp-idf/export.sh
```

## Advanced Options

### Custom Partition Table

The default partition table is at `xiaozhi-esp32/partitions/v2/16m.csv`. To modify:

1. Edit the partition CSV file
2. Update `CONFIG_PARTITION_TABLE_CUSTOM_FILENAME` in `sdkconfig.defaults`
3. Rebuild: `idf.py build`

### Over-the-Air (OTA) Updates

StackChan supports OTA updates. After initial flash via USB:

1. Configure WiFi on the device
2. Use the StackChan web interface or app for OTA updates
3. No USB cable required for updates

### Serial Debugging

For detailed debugging during boot:

```bash
# Monitor with timestamps
idf.py monitor

# In menuconfig, increase log verbosity:
idf.py menuconfig
# Component config -> Log output -> Default log verbosity -> Verbose
```

### Flash Only Specific Components

```bash
# Flash only the app (faster for development)
idf.py app-flash

# Flash only bootloader
idf.py bootloader-flash
```

## Development Workflow

### Recommended Workflow

1. **Develop UI in Emulator** (fast iteration)
   - See [Emulator Setup Guide](EMULATOR_SETUP.md)
   - Test and refine without hardware

2. **Build Firmware**
   ```bash
   cd firmware
   idf.py build
   ```

3. **Flash to CoreS3**
   ```bash
   idf.py flash monitor
   ```

4. **Test on Hardware**
   - Verify functionality
   - Test sensors, servos, etc.

5. **Iterate**
   - Make changes
   - Rebuild: `idf.py build`
   - Reflash: `idf.py app-flash` (faster)

### Quick Development Cycle

For code changes that don't affect bootloader or partitions:

```bash
# After making changes to source code:
idf.py app-flash monitor
```

This is faster than full `idf.py flash`.

## First Boot Checklist

After flashing for the first time:

- [ ] Device powers on
- [ ] Display shows StackChan UI
- [ ] Serial monitor shows clean boot (no errors)
- [ ] WiFi can be configured
- [ ] Servos respond to commands
- [ ] Camera works (if applicable)
- [ ] Touch screen is responsive
- [ ] Audio plays through speaker

## Differences: CoreS3 vs CoreS3 SE

Both use the same firmware, but:

**CoreS3:**
- Standard ESP32-S3 module
- 16MB Flash / 8MB PSRAM
- 2.0" LCD display

**CoreS3 SE (Special Edition):**
- Same specs as CoreS3
- May have different physical design
- Firmware is identical

No configuration changes needed - the firmware detects hardware automatically.

## Backup and Restore

### Backup Current Firmware

Before flashing, you can backup existing firmware:

```bash
# Read entire flash (takes several minutes)
esptool.py -p /dev/ttyUSB0 read_flash 0 0x1000000 backup.bin
```

### Restore from Backup

```bash
# Write backup back to flash
esptool.py -p /dev/ttyUSB0 write_flash 0 backup.bin
```

## Using Helper Scripts

For convenience, use the provided setup scripts:

```bash
# From StackChan root directory
./scripts/flash_stackchan.sh        # Linux/macOS
scripts\flash_stackchan.bat         # Windows
```

These scripts automate the build and flash process.

## Additional Resources

- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/en/v5.5.1/)
- [M5Stack CoreS3 Documentation](https://docs.m5stack.com/en/core/CoreS3)
- [StackChan Firmware README](../firmware/README.md)
- [Emulator Setup Guide](EMULATOR_SETUP.md)

## Getting Help

If you encounter issues:

1. Check serial monitor output: `idf.py monitor`
2. Review this troubleshooting section
3. Search [ESP-IDF issues](https://github.com/espressif/esp-idf/issues)
4. Check [M5Stack forums](https://community.m5stack.com/)
5. Open an issue in the StackChan repository

## Next Steps

After successful flashing:

1. Configure WiFi through the device interface
2. Set up StackChan World app connection
3. Customize avatar expressions and behaviors
4. Explore the XiaoZhi AI agent features
5. Join the StackChan community!

Happy developing!
