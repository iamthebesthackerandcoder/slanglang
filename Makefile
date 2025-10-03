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
