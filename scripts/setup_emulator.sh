#!/bin/bash
# StackChan Emulator Setup Script
# This script automates the setup of the M5Stack LVGL Emulator for StackChan development

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
EMULATOR_REPO="https://github.com/m5stack/lv_m5_emulator.git"
EMULATOR_DIR="${HOME}/lv_m5_emulator"
STACKCHAN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}StackChan Emulator Setup Script${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to install dependencies on Linux
install_linux_deps() {
    echo -e "${YELLOW}Installing dependencies for Linux...${NC}"

    if ! command -v apt-get &> /dev/null; then
        echo -e "${RED}This script currently supports Debian/Ubuntu systems.${NC}"
        echo -e "${YELLOW}Please install SDL2 manually for your distribution.${NC}"
        return 1
    fi

    echo "Installing SDL2 development libraries..."
    sudo apt-get update
    sudo apt-get install -y libsdl2-dev build-essential git pkg-config

    echo -e "${GREEN}Linux dependencies installed successfully!${NC}"
}

# Function to install dependencies on macOS
install_macos_deps() {
    echo -e "${YELLOW}Installing dependencies for macOS...${NC}"

    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Homebrew is not installed.${NC}"
        echo -e "${YELLOW}Please install Homebrew from https://brew.sh${NC}"
        echo ""
        echo "Run this command:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        return 1
    fi

    echo "Installing SDL2 and pkg-config..."
    brew install sdl2 pkg-config

    echo -e "${GREEN}macOS dependencies installed successfully!${NC}"
}

# Function to check if VS Code is installed
check_vscode() {
    if command -v code &> /dev/null; then
        echo -e "${GREEN}✓ Visual Studio Code is installed${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Visual Studio Code not found in PATH${NC}"
        echo -e "${YELLOW}Please install VS Code from https://code.visualstudio.com/${NC}"
        return 1
    fi
}

# Function to clone emulator repository
clone_emulator() {
    echo ""
    echo -e "${YELLOW}Cloning emulator repository...${NC}"

    if [ -d "$EMULATOR_DIR" ]; then
        echo -e "${YELLOW}Emulator directory already exists at $EMULATOR_DIR${NC}"
        read -p "Do you want to remove it and clone fresh? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$EMULATOR_DIR"
        else
            echo -e "${GREEN}Using existing emulator directory${NC}"
            return 0
        fi
    fi

    git clone "$EMULATOR_REPO" "$EMULATOR_DIR"
    echo -e "${GREEN}✓ Emulator repository cloned to $EMULATOR_DIR${NC}"
}

# Function to configure emulator for LVGL v9
configure_emulator() {
    echo ""
    echo -e "${YELLOW}Configuring emulator for LVGL v9...${NC}"

    local platformio_ini="$EMULATOR_DIR/platformio.ini"

    if [ ! -f "$platformio_ini" ]; then
        echo -e "${RED}platformio.ini not found!${NC}"
        return 1
    fi

    # Create backup
    cp "$platformio_ini" "$platformio_ini.backup"

    # Update build flags for LVGL v9
    if grep -q "LVGL_USE_V8" "$platformio_ini"; then
        sed -i.tmp 's/LVGL_USE_V8=1/LVGL_USE_V8=0/g' "$platformio_ini"
        sed -i.tmp 's/LVGL_USE_V9=0/LVGL_USE_V9=1/g' "$platformio_ini"
        rm -f "$platformio_ini.tmp"
        echo -e "${GREEN}✓ Updated LVGL version flags${NC}"
    else
        echo -e "${YELLOW}Note: You may need to manually configure LVGL v9 in platformio.ini${NC}"
    fi
}

# Function to create symlinks
create_symlinks() {
    echo ""
    echo -e "${YELLOW}Setting up symlinks to StackChan source files...${NC}"

    local emulator_src="$EMULATOR_DIR/src"

    read -p "Do you want to create symlinks to StackChan UI components? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        # Create symlinks for avatar and assets
        if [ -d "$STACKCHAN_ROOT/firmware/main/stackchan/avatar" ]; then
            ln -sf "$STACKCHAN_ROOT/firmware/main/stackchan/avatar" "$emulator_src/stackchan_avatar"
            echo -e "${GREEN}✓ Created symlink for avatar components${NC}"
        fi

        if [ -d "$STACKCHAN_ROOT/firmware/main/assets" ]; then
            ln -sf "$STACKCHAN_ROOT/firmware/main/assets" "$emulator_src/stackchan_assets"
            echo -e "${GREEN}✓ Created symlink for assets${NC}"
        fi

        echo -e "${YELLOW}Note: You'll need to update #include paths in your emulator main.cpp${NC}"
        echo -e "${YELLOW}to use these linked components.${NC}"
    fi
}

# Main setup flow
main() {
    local os_type=$(detect_os)

    # Step 1: Install dependencies
    echo -e "${YELLOW}Step 1: Installing dependencies${NC}"
    if [ "$os_type" == "linux" ]; then
        install_linux_deps
    elif [ "$os_type" == "macos" ]; then
        install_macos_deps
    else
        echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
        echo -e "${YELLOW}Please install SDL2 manually and re-run this script.${NC}"
        exit 1
    fi

    # Step 2: Check VS Code
    echo ""
    echo -e "${YELLOW}Step 2: Checking for Visual Studio Code${NC}"
    check_vscode || true

    # Step 3: Clone emulator
    echo ""
    echo -e "${YELLOW}Step 3: Setting up emulator repository${NC}"
    clone_emulator

    # Step 4: Configure emulator
    echo ""
    echo -e "${YELLOW}Step 4: Configuring emulator${NC}"
    configure_emulator

    # Step 5: Create symlinks
    echo ""
    echo -e "${YELLOW}Step 5: Linking StackChan components${NC}"
    create_symlinks

    # Final instructions
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}Setup Complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Open the emulator in VS Code:"
    echo "   ${GREEN}code $EMULATOR_DIR${NC}"
    echo ""
    echo "2. Install PlatformIO extension in VS Code if not already installed"
    echo ""
    echo "3. Review and customize the emulator's src/main.cpp to use StackChan components"
    echo ""
    echo "4. Build and run the emulator from VS Code's PlatformIO toolbar"
    echo ""
    echo "5. For detailed instructions, see:"
    echo "   ${GREEN}$STACKCHAN_ROOT/docs/EMULATOR_SETUP.md${NC}"
    echo ""
    echo -e "${YELLOW}Emulator location:${NC} $EMULATOR_DIR"
    echo -e "${YELLOW}StackChan location:${NC} $STACKCHAN_ROOT"
    echo ""
}

# Run main function
main
