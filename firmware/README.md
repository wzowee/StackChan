# StackChan Firmware

This directory contains the firmware source code for StackChan, built with ESP-IDF for the ESP32-S3 platform (M5Stack CoreS3/CoreS3 SE).

## Quick Start

For detailed instructions, see the [**Flashing Guide**](../docs/FLASHING_GUIDE.md).

### Prerequisites

- ESP-IDF v5.5.1 ([Installation Guide](https://docs.espressif.com/projects/esp-idf/en/v5.5.1/esp32s3/get-started/index.html))
- Python 3.8+
- M5Stack CoreS3 or CoreS3 SE

### Build and Flash

```bash
# 1. Fetch dependencies (first time only)
python3 ./fetch_repos.py

# 2. Build firmware
idf.py build

# 3. Flash to device
idf.py flash monitor
```

### Using Helper Script

From the StackChan root directory:

```bash
./scripts/flash_stackchan.sh  # Linux/macOS
scripts\flash_stackchan.bat   # Windows
```

## Documentation

- [**Flashing Guide**](../docs/FLASHING_GUIDE.md) - Complete setup and flashing instructions
- [**Flashing Quick Reference**](../docs/FLASHING_QUICK_REFERENCE.md) - Command cheatsheet
- [**Emulator Setup**](../docs/EMULATOR_SETUP.md) - Local development without hardware

## Tool Chains

[ESP-IDF v5.5.1](https://docs.espressif.com/projects/esp-idf/en/v5.5.1/esp32s3/index.html)

## Project Structure

```
firmware/
├── main/                    # Main application code
│   ├── apps/               # StackChan applications
│   ├── stackchan/          # Core StackChan components
│   ├── hal/                # Hardware abstraction layer
│   └── assets/             # Images, fonts, etc.
├── components/             # External components (via fetch_repos.py)
├── sdkconfig.defaults      # Default ESP-IDF configuration
└── CMakeLists.txt          # Build configuration
```
