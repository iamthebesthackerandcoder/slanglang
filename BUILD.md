# SlangLang Compiler - Build Process Documentation

## Overview
The SlangLang compiler is implemented in Julia and can be built for multiple platforms. The compiler translates Gen Z slang programming language code to Julia code, leveraging Julia's multiple dispatch and JIT compilation for performance.

## Prerequisites

### For Building
- Julia 1.10 or later
- PackageCompiler.jl (`julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"`)

### For Running
- Julia 1.10 or later (to execute generated code)
- Or the standalone executable built via PackageCompiler

## Windows Build Process

### Manual Build
1. Install Julia from https://julialang.org/
2. Install PackageCompiler:
   ```bash
   julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"
   ```
3. Navigate to the slanglang directory:
   ```bash
   cd path/to/slanglang
   ```
4. Run the build script:
   ```bash
   julia build_windows.jl
   ```
5. Execute the batch file to build the executable:
   ```bash
   build_windows.bat
   ```

### Build Output
- The compiled executable will be available at `slanglang_app/bin/slanglang.exe`
- This executable can run slang code without requiring Julia to be installed

## Linux/macOS Build Process

### Using Make
1. Install Julia from https://julialang.org/
2. Install PackageCompiler:
   ```bash
   julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"
   ```
3. Navigate to the slanglang directory:
   ```bash
   cd path/to/slanglang
   ```
4. Build using make:
   ```bash
   make
   ```

### Alternative: Using the Build Script
```bash
# Make the script executable
chmod +x build_linux.sh
# Run the build
./build_linux.sh
```

### Build Output
- The compiled executable will be available at `slanglang_app/bin/slanglang`
- This executable can run slang code without requiring Julia to be installed

## Cross-Platform Installation

### Using Cross-Platform Script
A cross-platform installation script is provided:

```bash
# Make the script executable
chmod +x install_cross_platform.sh
# Run installation
./install_cross_platform.sh
```

### Using Python Setup (Alternative)
```bash
pip install .
```

## Using the Compiler

### Command Line
```bash
# Compile slang file to Julia
slanglang input.slang output.jl

# Execute the generated Julia code
julia output.jl
```

### Example Usage
Create a slang file (`hello.slang`):
```
drop greet(name):
    tea "Hello, " + name + "!"

weak message = greet("World")
print(message)
```

Compile and run:
```bash
slanglang hello.slang hello.jl
julia hello.jl
```

## Development Build
For development and testing without building a full executable:
```bash
julia -i SlangLang.jl
```

Then in the Julia REPL:
```julia
using .SlangLang
code = "weak x = 42\\n"
julia_code = SlangLang.compile(code)
println(julia_code)  # Outputs: x = 42
```

## Troubleshooting

### Common Issues
1. **PackageCompiler not found**: Make sure to install it with `julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"`

2. **Build fails**: Ensure Julia is in your PATH and you have write permissions to the project directory

3. **Memory errors during build**: The PackageCompiler can be memory intensive - ensure you have sufficient RAM

### Performance
The compiler leverages Julia's JIT compilation for aggressive optimization. Generated code will have performance similar to hand-written Julia code.

## Deployment

### Standalone Executable
The build process creates a standalone executable that doesn't require Julia to be installed on the target machine.

### Library Usage
The compiler can also be used as a Julia module for integration into other projects.

## Project Structure
- `SlangLang.jl`: Main module containing the complete compiler
- `slanglang_main.jl`: Command-line interface entry point
- `build_windows.jl`: Windows build instructions
- `build_linux.sh`: Linux build script
- `Makefile`: Linux/macOS makefile
- `precompile_statements.jl`: Optimizations for faster startup
- `examples/`: Example slang programs
- `tests/`: Test suite