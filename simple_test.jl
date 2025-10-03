# Simple test to verify the compiler works
include("SlangLang.jl")
using .SlangLang

# Test a very simple statement
source = "weak x = 42\n"
println("Source: ", source)

try
    julia_code = SlangLang.compile(source)
    println("Generated Julia code: ", julia_code)
    println("Compilation successful!")
catch e
    println("Error: ", e)
    println("Stack trace:")
    showerror(stdout, e, catch_backtrace())
end