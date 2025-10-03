# slangpm.jl - Package Manager for SlangLang
# This tool helps manage SlangLang packages

module SlangPM

using Downloads
using JSON
using Pkg

"""
    init_package()

Initialize a new SlangLang package in the current directory.
"""
function init_package()
    # Create a default Project.toml file if it doesn't exist
    if !isfile("Project.toml")
        project_content = """
name = "MySlangPackage"
uuid = "$(Base.UUIDs.uuid4())"
version = "0.1.0"

[deps]
SlangLang = "12345678-1234-1234-1234-123456789abc"

[compat]
julia = "1.10"
SlangLang = "0.1"
"""
        write("Project.toml", project_content)
        println("Created Project.toml for your SlangLang package!")
    else
        println("Project.toml already exists in this directory.")
    end
    
    # Create a default package structure
    if !isdir("src")
        mkdir("src")
        package_file = """
module \$(basename(pwd()))

# Include your slanglang files here
# include(\"example.slang\")  # You'd compile this to Julia

end
"""
        write(joinpath("src", "\$(basename(pwd())).jl"), package_file)
        println("Created src/ directory with package template.")
    else
        println("src/ directory already exists.")
    end
    
    # Create a default test directory
    if !isdir("test")
        mkdir("test")
        test_file = """
using \$(basename(pwd()))
using Test

@testset "\$(basename(pwd()))" begin
    # Add your tests here
    @test 1 == 1
end
"""
        write(joinpath("test", "runtests.jl"), test_file)
        println("Created test/ directory with template.")
    else
        println("test/ directory already exists.")
    end
    
    println("SlangLang package initialized successfully!")
end

"""
    add_package(pkg_name::String)

Add a dependency to the current package.
"""
function add_package(pkg_name::String)
    if !isfile("Project.toml")
        error("No Project.toml found. Run slangpm init first.")
    end
    
    # Read the existing Project.toml
    content = read("Project.toml", String)
    
    # For now, we'll just add it to the deps section
    # In a real implementation, we would resolve versions and dependencies
    if occursin("[deps]", content)
        # Insert the dependency
        lines = split(content, '\n')
        new_lines = String[]
        for line in lines
            push!(new_lines, line)
            if startswith(line, "[deps]")
                push!(new_lines, "\$pkg_name = \"placeholder-uuid\"")
            end
        end
        content = join(new_lines, '\n')
    else
        # Add deps section
        content = content * "\n[deps]\n\$pkg_name = \"placeholder-uuid\"\n"
    end
    
    write("Project.toml", content)
    println("Added \$pkg_name as a dependency.")
end

"""
    install_packages()

Install all dependencies for the current package.
"""
function install_packages()
    if !isfile("Project.toml")
        error("No Project.toml found.")
    end
    
    # Use Julia's package manager to instantiate the project
    try
        Base.banner && Base.banner("Installing SlangLang package dependencies...")
        Pkg.activate(".")
        Pkg.instantiate()
        println("Dependencies installed successfully.")
    catch e
        println("Error installing dependencies: \$e")
    end
end

"""
    search_packages(query::String)

Search for packages in the SlangLang registry.
"""
function search_packages(query::String)
    # This would search a package registry in a real implementation
    # For now, we'll just show some example packages
    println("Searching for packages matching: \$query")
    println("Results (example):")
    println("- slang-math: Mathematical functions for SlangLang")
    println("- slang-web: Web development utilities")
    println("- slang-data: Data structures and algorithms")
    println("- slang-gui: GUI toolkit")
end

"""
    list_packages()

List all installed packages.
"""
function list_packages()
    if isfile("Project.toml")
        println("Project dependencies from Project.toml:")
        content = read("Project.toml", String)
        in_deps_section = false
        for line in split(content, '\n')
            if startswith(line, "[deps]")
                in_deps_section = true
            elseif startswith(line, "[")
                in_deps_section = false
            elseif in_deps_section && occursin("=", line)
                println("  \$line")
            end
        end
    else
        println("No Project.toml found in current directory.")
    end
end

"""
    update_packages()

Update all packages to their latest compatible versions.
"""
function update_packages()
    println("Updating SlangLang packages...")
    try
        Pkg.update()
        println("All packages updated successfully.")
    catch e
        println("Error updating packages: \$e")
    end
end

"""
    remove_package(pkg_name::String)

Remove a package dependency.
"""
function remove_package(pkg_name::String)
    if !isfile("Project.toml")
        error("No Project.toml found. Run slangpm init first.")
    end
    
    # Read the existing Project.toml
    content = read("Project.toml", String)
    
    # Remove the dependency
    lines = split(content, '\n')
    new_lines = String[]
    for line in lines
        if line != "\$pkg_name = \"placeholder-uuid\""
            push!(new_lines, line)
        end
    end
    content = join(new_lines, '\n')
    
    write("Project.toml", content)
    println("Removed \$pkg_name as a dependency.")
end

end  # module