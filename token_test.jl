# Debug test to see tokenization
include("src/compiler.jl")

source = "weak x = 42\n"
println("Source: ", source)

tokens = SlangCompiler.Tokenizer.tokenize(source)
for (i, token) in enumerate(tokens)
    println("Token $i: $(token.type) = $(token.value)")
end