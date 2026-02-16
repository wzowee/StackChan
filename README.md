# StackChan Open Source

<img src="https://vm.pledgebox.com/uploads/20251229/5sSmfjGLj9YYIzfHOSXQm4K00adu4Gv1.png" width="60%">

**Pre-order your StackChan**: https://m5stack.com/stackchan

> The software development is still in progress. Final features and documentation may change. Thank you for your understanding. 

<img src="https://cdn.shopify.com/s/files/1/0056/7689/2250/files/5a589623895f65487717894d9240f6b8.png" width="60%">

**StackChan is a super kawaii AI desktop robot co-created by M5Stack and the user community.** It uses the M5Stack **flagship IoT development kit [CoreS3](https://docs.m5stack.com/en/core/CoreS3)** as its main controller, powered by an ESP32-S3 SoC featuring a 240 MHz dual-core processor, with 16MB Flash and 8MB PSRAM onboard, and supporting Wi-Fi and BLE. The main unit also integrates a 2.0-inch capacitive touch display with a high-strength glass cover, a 0.3 MP camera, a proximity sensor, a 9-axis IMU (accelerometer + gyroscope + magnetometer), a microSD card slot, a 1W speaker, dual microphones, and power/reset buttons. 

The **robot body**, connected to the main unit, includes a USB-C interface for power and data, a 700 mAh battery, two feedback servos (360-degree continuous rotation on the horizontal axis and 90-degree movement on the vertical axis), two rows totaling 12 RGB LEDs, infrared transmitter and receiver, a three-zone touch panel, and a full-featured NFC module. 

The **factory firmware** comes with rich features, including vivid and cute facial expressions and motions, the XiaoZhi AI agent, as well as support for iOS app video calls, remote avatars, and discovering other nearby StackChan devices. The product also supports programming via Arduino and UiFlow2, making it easy to implement a wide range of custom functionalities. 

> Do not forcibly rotate any movable parts connected to the motors by hand when you are unsure whether the motors are powered and under control, as this may cause hardware damage. 

- **StackChan World iOS app**: https://apps.apple.com/app/stackchan-world/id6756086326

- **StackChan World website**: https://stackchan.world/home

## Development

### Flashing Firmware to CoreS3/CoreS3 SE

Ready to build and flash StackChan firmware to your M5Stack CoreS3 or CoreS3 SE board?

See the [Flashing Guide](docs/FLASHING_GUIDE.md) for complete instructions on setting up ESP-IDF and flashing firmware.

Quick start:
```bash
# Use the automated flash helper
./scripts/flash_stackchan.sh  # Linux/macOS
# or
scripts\flash_stackchan.bat   # Windows
```

Manual flashing:
```bash
cd firmware
python3 ./fetch_repos.py  # Fetch dependencies (first time only)
idf.py build              # Build firmware
idf.py flash monitor      # Flash and monitor
```

### Local Development with Emulator

Want to develop and test StackChan UI changes without constantly flashing firmware to your device? Use the M5Stack LVGL Emulator for rapid local development.

See the [Emulator Setup Guide](docs/EMULATOR_SETUP.md) for detailed instructions on setting up the emulator on your PC.

Quick start:
```bash
# Run the automated setup script
./scripts/setup_emulator.sh  # Linux/macOS
# or
scripts\setup_emulator.bat   # Windows
```
