# Windows build script for SlangLang compiler
# This script creates a Windows executable for the slang compiler

@info "Building Windows executable for SlangLang compiler..."

# First, create a project structure to bundle the compiler
# We'll create a main script that serves as the executable entry point

# Create a main entry point for the executable
main_script = raw"""
include("SlangLang.jl")
using .SlangLang

# Main entry point for command-line usage
function main()
    if length(ARGS) < 1
        println("Usage: slanglang.exe <input_file.slang> [output_file.jl]")
        return
    end
    
    input_file = ARGS[1]
    
    # Determine output file
    output_file = if length(ARGS) > 1
        ARGS[2]
    else
        # Generate output filename by replacing .slang with .jl
        if endswith(input_file, ".slang")
            input_file[1:end-5] * ".jl"
        else
            input_file * ".jl"
        end
    end
    
    # Read slang source
    slang_code = read(input_file, String)
    
    try
        # Compile to Julia code
        julia_code = SlangLang.compile(slang_code)
        
        # Write to output file
        write(output_file, julia_code)
        
        println("Successfully compiled $input_file to $output_file")
    catch e
        println("Error compiling $input_file: $e")
        Base.show_backtrace(stdout, catch_backtrace())
        exit(1)
    end
end

# Run main if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
"""

# Write the main script
write("slanglang_main.jl", main_script)

println("Created main script for compilation...")

# Now create a build script that uses PackageCompiler
build_script = raw"""
using PackageCompiler

# Create a sysimage for faster startup
println("Creating sysimage...")
PackageCompiler.create_sysimage(:SlangLang; 
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
    force=true
)

println("Windows executable build completed!")
println("Find the executable in: slanglang_app/bin/slanglang.exe")
"""

# Write the build script
write("build_windows.jl", build_script)

# Create a precompile statements file to improve startup time
precompile_script = raw"""
# Precompile statements for SlangLang compiler
include("SlangLang.jl")
using .SlangLang

# Precompile common operations
function precompile_functions()
    # Tokenize a simple statement
    tokens = SlangLang.Tokenizer.tokenize("weak x = 42\n")
    
    # Parse a simple program
    parser = SlangLang.Parser.SlangParser(tokens)
    ast = SlangLang.Parser.parse_program(parser)
    
    # Generate code
    code = SlangLang.CodeGenerator.generate_code(ast)
    
    # Run semantic analysis
    context = SlangLang.SemanticAnalyzer.SemanticContext()
    errors = SlangLang.SemanticAnalyzer.analyze(ast, context)
    
    return code
end

precompile_functions()
"""

write("precompile_statements.jl", precompile_script)

println("Created build scripts for Windows executable:")
println("- slanglang_main.jl: Main entry point")
println("- build_windows.jl: Build script")
println("- precompile_statements.jl: Precompile optimization")

# Create a batch file for easy building
batch_script = raw"""
@echo off
echo Building SlangLang compiler for Windows...

REM Install PackageCompiler if not already installed
julia -e "using Pkg; Pkg.add(\"PackageCompiler\")"

REM Run the build script
julia build_windows.jl

echo Build process completed!
pause
"""

write("build_windows.bat", batch_script)

println("Created build_windows.bat for easy building")