# Step-by-step parsing test
include("src/compiler.jl")
using .SlangCompiler

# Test step by step
source = "weak x = 42\n"
println("Source: ", source)

# Step 1: Tokenize the source
tokens = SlangCompiler.Tokenizer.tokenize(source)
println("Tokens: ")
for (i, token) in enumerate(tokens)
    println("  $i: $(token.type) = $(repr(token.value))")
end

# Step 2: Create parser and check initial state
parser = SlangCompiler.Parser.SlangParser(tokens)
println("\nInitial parser state:")
println("  Current token: $(parser.current_token.type) = $(repr(parser.current_token.value))")
println("  Current: $(parser.current)")

# Step 3: Check WEAK condition
is_weak = SlangCompiler.Parser.check(parser, SlangCompiler.Tokenizer.WEAK)
println("\nCheck WEAK: $is_weak")

if is_weak
    println("Taking WEAK branch...")
    
    # Manually execute what should happen in the weak branch
    println("\nBefore advance (should be WEAK): $(parser.current_token.type) = $(repr(parser.current_token.value))")
    SlangCompiler.Parser.advance!(parser)
    println("After advance (should be IDENTIFIER 'x'): $(parser.current_token.type) = $(repr(parser.current_token.value))")
    
    # Check if we can expect IDENTIFIER
    if SlangCompiler.Parser.check(parser, SlangCompiler.Tokenizer.IDENTIFIER)
        println("Current token is IDENTIFIER, proceeding with expect...")
        token = parser.current_token
        SlangCompiler.Parser.advance!(parser)  # This effectively does expect
        target_value = token.value
        println("Target value extracted: $(repr(target_value))")
        
        # Check next token should be ASSIGN
        println("Next token (should be ASSIGN): $(parser.current_token.type) = $(repr(parser.current_token.value))")
        
        # If target_value is "=", then we found the issue
        if target_value == "="
            println("ERROR: Got assignment token instead of identifier!")
        end
    else
        println("ERROR: Expected IDENTIFIER but got $(parser.current_token.type)")
    end
else
    println("ERROR: WEAK check failed, shouldn't happen based on previous tests")
end