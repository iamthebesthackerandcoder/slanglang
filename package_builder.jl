# Package builder for SlangLang
# This script creates distribution packages for different platforms

using PackageCompiler

# Create a sysimage for faster startup
println("Creating system image for SlangLang...")
create_sysimage([:SlangLang], 
                sysimage_path="slanglang_sys.so",
                precompile_statements_file="precompile_statements.jl")

println("System image created successfully!")

# Function to build executable
function build_executable()
    # Create a standalone executable
    package_path = pwd()
    output_dir = joinpath(package_path, "dist")
    
    # Ensure dist directory exists
    mkpath(output_dir)
    
    # Create the executable using PackageCompiler
    create_app(
        package_path,
        joinpath(output_dir, "slanglang_app");
        executables=["slanglang_main.jl" => "slanglang"],
        precompile_execution_file="simple_test.jl",
        include_transitive_dependencies=true,
        incremental=true
    )
    
    println("Executable created in dist/slanglang_app/")
end

# Build the executable
build_executable()