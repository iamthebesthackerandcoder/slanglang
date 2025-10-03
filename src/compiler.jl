# compiler.jl - Main compiler functions for SlangLang

using ..Tokenizer
using ..Parser
using ..SemanticAnalyzer
using ..CodeGenerator

"""
Main compiler function that takes slang source code and returns Julia code
"""
function compile(source_code::String)
    # Step 1: Tokenize the source
    tokens = Tokenizer.tokenize(source_code)
    
    # Step 2: Parse tokens into AST
    parser = Parser.SlangParser(tokens)
    ast = Parser.parse_program(parser)
    
    # Step 3: Perform semantic analysis
    context = SemanticAnalyzer.SemanticContext()
    errors = SemanticAnalyzer.analyze(ast, context)
    
    if !isempty(errors)
        for error in errors
            println("Semantic Error: $error")
        end
        error("Compilation failed due to semantic errors")
    end
    
    # Step 4: Generate Julia code
    julia_code = CodeGenerator.generate_code(ast)
    
    return julia_code
end

"""
Compile and execute slang code directly
"""
function compile_and_execute(source_code::String)
    julia_code = compile(source_code)
    # Execute the generated Julia code
    return eval(Meta.parse(julia_code))
end