# Simple assignment test without weak
include("src/compiler.jl")
using .SlangCompiler

# Test simple assignment (without weak/strong)
source = "x = 42\n"
println("Source: ", source)

try
    # Step 1: Tokenize the source
    tokens = SlangCompiler.Tokenizer.tokenize(source)
    println("Tokens: ")
    for (i, token) in enumerate(tokens)
        if i <= 10  # Limit output
            println("  $i: $(token.type) = $(repr(token.value))")
        end
    end
    
    # Step 2: Parse tokens into AST
    parser = SlangCompiler.Parser.SlangParser(tokens)
    ast = SlangCompiler.Parser.parse_program(parser)
    println("\nAST: ", ast)
    
    # Print details about the assignment
    if !isempty(ast.statements) && length(ast.statements) > 0
        stmt = ast.statements[1]
        println("Statement type: ", typeof(stmt))
        if typeof(stmt) == SlangCompiler.Core.AST.AssignmentStmt
            assignment = stmt
            println("Left side: ", assignment.target)
            println("Right side: ", assignment.value)
            if typeof(assignment.target) == SlangCompiler.Core.AST.Identifier
                println("Left side name: ", assignment.target.name)
            end
        end
    end
    
    # Step 3: Generate Julia code
    julia_code = SlangCompiler.CodeGenerator.generate_code(ast)
    println("\nGenerated Julia code: $(repr(julia_code))")
    println("Compilation successful!")
catch e
    println("Error: ", e)
    println("Stack trace:")
    showerror(stdout, e, catch_backtrace())
end