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
