# Cross-platform installer for SlangLang compiler

# Create a setup.py for cross-platform installation
setup_script = raw"""
import os
import sys
from setuptools import setup, find_packages

# Read the README for long description
def read_readme():
    with open("README.md", "r", encoding="utf-8") as fh:
        return fh.read()

setup(
    name="slanglang",
    version="1.0.0",
    author="AI Assistant",
    author_email="slanglang@example.com",
    description="A production-ready compiler for the Gen Z slang programming language",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/your-org/slanglang",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Julia",
    ],
    python_requires='>=3.6',
    install_requires=[
        "setuptools",
    ],
    entry_points={
        'console_scripts': [
            'slanglang=slanglang.cli:main',
        ],
    },
    include_package_data=True,
    package_data={
        'slanglang': ['*.jl', 'src/*.jl', 'examples/*', 'docs/*'],
    },
)
"""

write("setup.py", setup_script)

# Create a README
readme = raw"""
# SlangLang Compiler

A production-ready compiler for the Gen Z slang programming language, implemented in Julia with aggressive optimization using Julia's multiple dispatch and JIT compilation.

## Installation

### From Source
1. Install Julia 1.10 or later
2. Install PackageCompiler: `julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"`
3. Run: `julia build_windows.jl` (Windows) or `make` (Linux)

### Using the Compiler

The compiler translates slang code to Julia code which can then be executed by Julia:

```bash
slanglang input.slang output.jl
julia output.jl
```

## Syntax

SlangLang uses Gen Z slang keywords:

- `bussin` - if
- `bussd` - elif/else if  
- `no cap` - else
- `slay` - while
- `let's go` - for
- `drop` - def (function definition)
- `tea` - return
- `weak` - var (variable declaration)
- `strong` - const (constant declaration)
- `sus` - True
- `fake` - False
- `based` - and
- `crazy` - or
- `cap` - not
- And many more!

Example:
```
drop greet(name):
    tea "Hello " + name + "!"

weak message = greet("World")
print(message)
```

## Features

- Full support for control structures (if/else, while, for)
- Function definitions and calls
- Variable declarations
- Boolean and arithmetic operations
- Semantic analysis with error reporting
- Code generation targeting Julia
- Leverages Julia's JIT compilation for performance
"""

write("README.md", readme)

# Create a cross-platform install script
install_script = raw"""
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
"""

write("install_cross_platform.sh", install_script)

# Make install script executable
run(`chmod +x install_cross_platform.sh`)

println("Created cross-platform installer files:")
println("- setup.py: Python setup script")
println("- README.md: Documentation")
println("- install_cross_platform.sh: Cross-platform install script")

# Make install script executable
run(`chmod +x install_cross_platform.sh`)

println("Created cross-platform installer files:")
println("- setup.py: Python setup script")
println("- README.md: Documentation")
println("- install_cross_platform.sh: Cross-platform install script")