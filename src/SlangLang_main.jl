module SlangLang

# Re-export the public API from the main module
include(joinpath(@__DIR__, "..", "SlangLang.jl"))

# Export the main functions
export compile, compile_and_execute

end