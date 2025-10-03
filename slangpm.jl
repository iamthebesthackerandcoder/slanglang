#!/usr/bin/env julia

# slangpm - Command line interface for SlangLang Package Manager

include("src/SlangLang.jl")
include("src/SlangPM.jl")

using .SlangPM

function show_help()
    println("SlangLang Package Manager (slangpm)")
    println("Usage: slangpm [command] [options]")
    println()
    println("Commands:")
    println("  init              Initialize a new SlangLang package in the current directory")
    println("  add <package>     Add a package dependency")
    println("  install           Install all dependencies")
    println("  search <query>    Search for packages")
    println("  list              List installed packages")
    println("  update            Update all packages")
    println("  remove <package>  Remove a package dependency")
    println("  help              Show this help message")
    println()
end

function main()
    if length(ARGS) == 0
        show_help()
        return
    end
    
    command = ARGS[1]
    
    try
        if command == "init"
            SlangPM.init_package()
        elseif command == "add"
            if length(ARGS) < 2
                println("Error: Please specify a package name to add")
                return
            end
            SlangPM.add_package(ARGS[2])
        elseif command == "install"
            SlangPM.install_packages()
        elseif command == "search"
            if length(ARGS) < 2
                println("Error: Please specify a search query")
                return
            end
            SlangPM.search_packages(ARGS[2])
        elseif command == "list"
            SlangPM.list_packages()
        elseif command == "update"
            SlangPM.update_packages()
        elseif command == "remove"
            if length(ARGS) < 2
                println("Error: Please specify a package name to remove")
                return
            end
            SlangPM.remove_package(ARGS[2])
        elseif command == "help" || command == "--help" || command == "-h"
            show_help()
        else
            println("Unknown command: \$command")
            println()
            show_help()
        end
    catch e
        println("Error: \$e")
    end
end

# Run main if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end