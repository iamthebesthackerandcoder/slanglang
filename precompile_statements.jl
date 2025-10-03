# Precompile statements for SlangLang compiler
include("SlangLang.jl")
using .SlangLang

# Precompile common operations
function precompile_functions()
    # Tokenize a simple statement
    tokens = SlangLang.Tokenizer.tokenize("weak x = 42\n")
    
    # Parse a simple program
    parser = SlangLang.Parser.SlangParser(tokens)
    ast = SlangLang.Parser.parse_program(parser)
    
    # Generate code
    code = SlangLang.CodeGenerator.generate_code(ast)
    
    # Run semantic analysis
    context = SlangLang.SemanticAnalyzer.SemanticContext()
    errors = SlangLang.SemanticAnalyzer.analyze(ast, context)
    
    return code
end

precompile_functions()
