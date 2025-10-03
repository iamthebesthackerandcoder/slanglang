# SlangLang.jl - A Julia package for the SlangLang programming language

module SlangLang

# Export key functions
export compile, compile_and_execute

# Include submodules
include("tokenizer.jl")
include("ast.jl")
include("parser.jl")
include("semantic_analyzer.jl")
include("code_generator.jl")
include("compiler.jl")

# Add methods to Base module if needed
# This allows functions to work with existing Julia functionality

end # module