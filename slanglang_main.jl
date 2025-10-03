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
