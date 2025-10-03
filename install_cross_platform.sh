#!/bin/bash
# Cross-platform installation script for SlangLang

OS_NAME=\$(uname -s)

echo "Detecting operating system..."
case \$OS_NAME in
    Linux*)
        echo "Detected Linux"
        if [ -f "build_linux.sh" ]; then
            echo "Building for Linux..."
            chmod +x build_linux.sh
            ./build_linux.sh
            echo "Linux build completed"
        else
            echo "build_linux.sh not found"
            exit 1
        fi
        ;;
    Darwin*)
        echo "Detected macOS"
        if [ -f "Makefile" ]; then
            echo "Building for macOS..."
            make
            echo "macOS build completed"
        else
            echo "Makefile not found"
            exit 1
        fi
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo "Detected Windows (Cygwin/Git Bash)"
        if [ -f "build_windows.bat" ]; then
            echo "Building for Windows..."
            cmd /c build_windows.bat
            echo "Windows build completed"
        else
            echo "build_windows.bat not found"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system: \$OS_NAME"
        echo "Please build manually using Julia and PackageCompiler"
        exit 1
        ;;
esac

echo "Installation completed!"
