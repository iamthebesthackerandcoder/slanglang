# Linux build script for SlangLang compiler
# This script creates a Linux executable for the slang compiler

# Create a bash script for building on Linux
build_script = raw"""
#!/bin/bash

echo "Building SlangLang compiler for Linux..."

# Install PackageCompiler if not already installed
julia -e 'using Pkg; Pkg.add("PackageCompiler")'

# Run the build process
julia << EOF
using PackageCompiler

# Create a sysimage for faster startup
println("Creating sysimage...")
PackageCompiler.create_sysimage([:SlangLang]; 
    sysimage_path="slanglang_sys.so",
    precompile_statements_file="precompile_statements.jl"
)

println("Building executable...")
PackageCompiler.create_app(
    pwd(),                    # source directory  
    "slanglang_app",          # app directory name
    precompile_statements_file="precompile_statements.jl",
    include_transitive_dependencies=true,
    incremental=true,
    force=true,
    executables=["slanglang_main.jl" => "slanglang"]
)

println("Linux executable build completed!")
println("Find the executable in: slanglang_app/bin/slanglang")
EOF

echo "Linux build process completed!"
"""

write("build_linux.sh", build_script)

# Make the script executable
run(`chmod +x build_linux.sh`)

# Create a Makefile for Linux
makefile = raw"""
# Makefile for SlangLang compiler

.PHONY: all build install clean

JULIA=julia
PACKAGE_COMPILER_INSTALLED := \$(shell \$(JULIA) -e 'Base.banner()'; echo $$? 2>/dev/null)

all: build

build: 
	@echo "Building SlangLang compiler..."
	@\$(JULIA) -e 'using Pkg; Pkg.add("PackageCompiler"); using PackageCompiler; create_app(pwd(), "slanglang_app", precompile_statements_file="precompile_statements.jl", include_transitive_dependencies=true, incremental=true, force=true, executables=["slanglang_main.jl" => "slanglang"])'
	@echo "Build completed. Find executable in slanglang_app/bin/slanglang"

install: build
	@echo "Installing SlangLang compiler..."
	@cp slanglang_app/bin/slanglang /usr/local/bin/ 2>/dev/null || echo "Need sudo for installation: sudo make install_sudo"
	
install_sudo:
	@sudo cp slanglang_app/bin/slanglang /usr/local/bin/
	@echo "SlangLang compiler installed to /usr/local/bin/slanglang"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf slanglang_app/ slanglang_sys.so 2>/dev/null || true
	@echo "Clean completed"
"""

write("Makefile", makefile)

println("Created build scripts for Linux:")
println("- build_linux.sh: Bash script for building")
println("- Makefile: Makefile for building and installation")