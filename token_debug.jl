# Debug test to see token matching
include("src/compiler.jl")
using .SlangCompiler

# Test a very simple statement
source = "weak x = 42\n"
println("Source: ", source)

# Step 1: Tokenize the source
tokens = SlangCompiler.Tokenizer.tokenize(source)
println("Tokens: ")
for (i, token) in enumerate(tokens)
    if i <= 10  # Limit output
        println("  $i: $(token.type) = $(repr(token.value))")
    end
end

# Check if WEAK token matches
first_token = tokens[1]
println("\nFirst token type: ", first_token.type)
println("Tokenizer.WEAK: ", SlangCompiler.Tokenizer.WEAK)
println("Are they equal? ", first_token.type == SlangCompiler.Tokenizer.WEAK)

# Create a simple parser and check
parser = SlangCompiler.Parser.SlangParser(tokens)
println("Parser current token: ", parser.current_token)
println("Check WEAK: ", SlangCompiler.Parser.check(parser, SlangCompiler.Tokenizer.WEAK))