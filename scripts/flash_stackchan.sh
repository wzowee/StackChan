#!/bin/bash
# StackChan Firmware Flash Helper Script
# Automates the build and flash process for CoreS3/CoreS3 SE

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKCHAN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRMWARE_DIR="$STACKCHAN_ROOT/firmware"

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}StackChan Firmware Flash Helper${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Function to check if ESP-IDF is available
check_idf() {
    if ! command -v idf.py &> /dev/null; then
        echo -e "${RED}ERROR: ESP-IDF not found!${NC}"
        echo ""
        echo "Please install ESP-IDF v5.5.1 and source the environment:"
        echo ""
        echo -e "${YELLOW}  . ~/esp/esp-idf/export.sh${NC}"
        echo ""
        echo "Or add to your ~/.bashrc:"
        echo -e "${YELLOW}  alias get_idf='. ~/esp/esp-idf/export.sh'${NC}"
        echo ""
        echo "For installation instructions, see:"
        echo -e "${BLUE}  $STACKCHAN_ROOT/docs/FLASHING_GUIDE.md${NC}"
        exit 1
    fi

    # Check version
    local idf_version=$(idf.py --version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' | head -1)
    echo -e "${GREEN}✓ ESP-IDF found: $idf_version${NC}"

    if [[ "$idf_version" != "v5.5.1" ]]; then
        echo -e "${YELLOW}⚠ Warning: Expected ESP-IDF v5.5.1, found $idf_version${NC}"
        echo -e "${YELLOW}  This may cause compatibility issues.${NC}"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to fetch dependencies
fetch_dependencies() {
    echo ""
    echo -e "${YELLOW}Checking dependencies...${NC}"

    if [ ! -d "$FIRMWARE_DIR/components/mooncake" ]; then
        echo -e "${YELLOW}Dependencies not found. Fetching...${NC}"
        cd "$FIRMWARE_DIR"
        python3 ./fetch_repos.py
        echo -e "${GREEN}✓ Dependencies fetched${NC}"
    else
        echo -e "${GREEN}✓ Dependencies already present${NC}"
        read -p "Re-fetch dependencies? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$FIRMWARE_DIR"
            python3 ./fetch_repos.py
        fi
    fi
}

# Function to detect serial port
detect_port() {
    echo ""
    echo -e "${YELLOW}Detecting serial port...${NC}"

    local ports=()

    # Check common Linux/macOS ports
    if [[ -e /dev/ttyUSB0 ]]; then
        ports+=("/dev/ttyUSB0")
    fi
    if [[ -e /dev/ttyACM0 ]]; then
        ports+=("/dev/ttyACM0")
    fi

    # Check for macOS USB serial ports
    for port in /dev/cu.usbserial-* /dev/cu.SLAB_USBtoUART /dev/cu.wchusbserial*; do
        if [[ -e "$port" ]]; then
            ports+=("$port")
        fi
    done

    if [ ${#ports[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠ No serial ports detected${NC}"
        echo ""
        echo "Please connect your CoreS3/CoreS3 SE and try again."
        echo "Will attempt auto-detection during flash..."
        SERIAL_PORT=""
    elif [ ${#ports[@]} -eq 1 ]; then
        SERIAL_PORT="${ports[0]}"
        echo -e "${GREEN}✓ Found port: $SERIAL_PORT${NC}"
    else
        echo -e "${YELLOW}Multiple ports found:${NC}"
        select port in "${ports[@]}" "Enter manually" "Auto-detect"; do
            if [ "$port" = "Enter manually" ]; then
                read -p "Enter port path: " SERIAL_PORT
                break
            elif [ "$port" = "Auto-detect" ]; then
                SERIAL_PORT=""
                break
            elif [ -n "$port" ]; then
                SERIAL_PORT="$port"
                break
            fi
        done
    fi
}

# Function to build firmware
build_firmware() {
    echo ""
    echo -e "${YELLOW}Building firmware...${NC}"
    echo -e "${BLUE}This may take 5-15 minutes on first build...${NC}"
    echo ""

    cd "$FIRMWARE_DIR"

    if idf.py build; then
        echo ""
        echo -e "${GREEN}✓ Build successful!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ Build failed${NC}"
        echo ""
        echo "Common solutions:"
        echo "1. Run: idf.py fullclean && idf.py build"
        echo "2. Re-fetch dependencies: python3 ./fetch_repos.py"
        echo "3. Check ESP-IDF version: idf.py --version"
        echo ""
        return 1
    fi
}

# Function to flash firmware
flash_firmware() {
    echo ""
    echo -e "${YELLOW}Flashing firmware to CoreS3...${NC}"
    echo ""

    cd "$FIRMWARE_DIR"

    local flash_cmd="idf.py"
    if [ -n "$SERIAL_PORT" ]; then
        flash_cmd="$flash_cmd -p $SERIAL_PORT"
    fi
    flash_cmd="$flash_cmd flash"

    if eval $flash_cmd; then
        echo ""
        echo -e "${GREEN}✓ Flash successful!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ Flash failed${NC}"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check USB cable connection"
        echo "2. Hold RESET button while flashing"
        echo "3. Try: idf.py -b 115200 flash (slower baud rate)"
        echo "4. Check: ls /dev/tty* to find correct port"
        echo ""
        return 1
    fi
}

# Function to monitor serial output
monitor_serial() {
    echo ""
    echo -e "${YELLOW}Starting serial monitor...${NC}"
    echo -e "${BLUE}Press Ctrl+] to exit${NC}"
    echo ""

    cd "$FIRMWARE_DIR"

    local monitor_cmd="idf.py"
    if [ -n "$SERIAL_PORT" ]; then
        monitor_cmd="$monitor_cmd -p $SERIAL_PORT"
    fi
    monitor_cmd="$monitor_cmd monitor"

    eval $monitor_cmd
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}What would you like to do?${NC}"
    echo "1) Build and flash firmware"
    echo "2) Build only"
    echo "3) Flash only (skip build)"
    echo "4) Flash and monitor"
    echo "5) Monitor only"
    echo "6) Clean build"
    echo "7) Full clean and rebuild"
    echo "8) Erase flash"
    echo "9) Exit"
    echo ""
}

# Main script execution
main() {
    # Initial checks
    check_idf
    fetch_dependencies

    # Main loop
    while true; do
        show_menu
        read -p "Select option [1-9]: " choice

        case $choice in
            1)
                detect_port
                build_firmware && flash_firmware
                ;;
            2)
                build_firmware
                ;;
            3)
                detect_port
                flash_firmware
                ;;
            4)
                detect_port
                build_firmware && flash_firmware && monitor_serial
                ;;
            5)
                detect_port
                monitor_serial
                ;;
            6)
                cd "$FIRMWARE_DIR"
                echo -e "${YELLOW}Cleaning build...${NC}"
                idf.py clean
                echo -e "${GREEN}✓ Clean complete${NC}"
                build_firmware
                ;;
            7)
                cd "$FIRMWARE_DIR"
                echo -e "${YELLOW}Full clean...${NC}"
                idf.py fullclean
                echo -e "${GREEN}✓ Full clean complete${NC}"
                build_firmware
                ;;
            8)
                detect_port
                cd "$FIRMWARE_DIR"
                echo -e "${RED}WARNING: This will erase all data on the device!${NC}"
                read -p "Are you sure? (yes/N): " -r
                if [[ $REPLY == "yes" ]]; then
                    local erase_cmd="idf.py"
                    if [ -n "$SERIAL_PORT" ]; then
                        erase_cmd="$erase_cmd -p $SERIAL_PORT"
                    fi
                    erase_cmd="$erase_cmd erase-flash"
                    eval $erase_cmd
                    echo -e "${GREEN}✓ Flash erased${NC}"
                else
                    echo "Cancelled"
                fi
                ;;
            9)
                echo ""
                echo -e "${GREEN}Done! Happy hacking with StackChan!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                ;;
        esac

        # Ask to continue or exit
        echo ""
        read -p "Press Enter to continue or Ctrl+C to exit..."
    done
}

# Run main function
main
