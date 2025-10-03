# Debug test to see full AST
include("SlangLang.jl")
using .SlangLang

# Test a very simple statement
source = "weak x = 42\n"
println("Source: ", source)

try
    # Step 1: Tokenize the source
    tokens = SlangLang.Tokenizer.tokenize(source)
    println("Tokens: ")
    for (i, token) in enumerate(tokens)
        if i <= 10  # Limit output
            println("  $i: $(token.type) = $(repr(token.value))")
        end
    end
    
    # Step 2: Parse tokens into AST
    parser = SlangLang.Parser.SlangParser(tokens)
    ast = SlangLang.Parser.parse_program(parser)
    println("\nAST: ", ast)
    
    # Print details about the assignment
    if !isempty(ast.statements) && length(ast.statements) > 0 && typeof(ast.statements[1]) == SlangLang.AST.AssignmentStmt
        assignment = ast.statements[1]
        println("Left side: ", assignment.target)
        println("Right side: ", assignment.value)
        if typeof(assignment.target) == SlangLang.AST.Identifier
            println("Left side name: ", assignment.target.name)
        end
    end
    
    # Step 3: Generate Julia code
    julia_code = SlangLang.CodeGenerator.generate_code(ast)
    println("\nGenerated Julia code: ", repr(julia_code))
    println("Compilation successful!")
catch e
    println("Error: ", e)
    println("Stack trace:")
    showerror(stdout, e, catch_backtrace())
end