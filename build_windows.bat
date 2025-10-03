@echo off
echo Building SlangLang compiler for Windows...

REM Install PackageCompiler if not already installed
julia -e "using Pkg; Pkg.add("PackageCompiler")"

REM Run the build script
julia build_windows.jl

echo Build process completed!
pause
