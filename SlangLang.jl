# Main SlangLang compiler module
module SlangLang

# Define AST as part of this module to be shared
module AST

# Base abstract types for AST nodes
abstract type ASTNode end

# Statement types
abstract type Statement <: ASTNode end
abstract type Expression <: ASTNode end

# Program node
mutable struct Program <: ASTNode
    statements::Vector{Statement}
end

# Statement types
mutable struct FunctionDef <: Statement
    name::String
    parameters::Vector{String}
    body::Vector{Statement}
end

mutable struct ClassDef <: Statement
    name::String
    body::Vector{Statement}
end

mutable struct ModuleDef <: Statement
    name::String
    body::Vector{Statement}
end

mutable struct IfStmt <: Statement
    condition::Expression
    if_body::Vector{Statement}
    elif_clauses::Vector{Tuple{Expression, Vector{Statement}}} # (condition, body)
    else_body::Union{Vector{Statement}, Nothing}
end

mutable struct WhileStmt <: Statement
    condition::Expression
    body::Vector{Statement}
end

mutable struct ForStmt <: Statement
    variable::String
    iterable::Expression
    body::Vector{Statement}
end

mutable struct TryStmt <: Statement
    try_body::Vector{Statement}
    except_body::Vector{Statement}
end

mutable struct AssignmentStmt <: Statement
    target::Expression
    value::Expression
end

mutable struct ReturnStmt <: Statement
    value::Union{Expression, Nothing}
end

mutable struct BreakStmt <: Statement
end

mutable struct ContinueStmt <: Statement
end

mutable struct ExpressionStmt <: Statement
    expression::Expression
end

mutable struct ImportStmt <: Statement
    module_name::String
end

mutable struct AssertStmt <: Statement
    condition::Expression
end

mutable struct RaiseStmt <: Statement
    expression::Expression
end

mutable struct PassStmt <: Statement
end

# Expression types
mutable struct Literal <: Expression
    value
end

mutable struct Identifier <: Expression
    name::String
end

mutable struct BinaryOp <: Expression
    left::Expression
    op::String
    right::Expression
end

mutable struct UnaryOp <: Expression
    op::String
    operand::Expression
end

mutable struct Call <: Expression
    func::String
    args::Vector{Expression}
end

end  # AST module

# Import AST for convenience
using .AST

# Tokenizer module
module Tokenizer
    # Define token types
    @enum TokenType begin
        # Keywords
        BUSSIN      # if
        BUSSD       # elif
        NOCAP       # else
        SLAY        # while
        LETSGO      # for
        PERIODT     # break
        SKSKSK      # continue
        DROP        # def
        TEA         # return
        MAINCHARACTER # class
        FLEX        # struct/class
        WEAK        # var
        STRONG      # const
        SUS         # True
        FAKE        # False
        BASED       # and
        CRAZY       # or
        CAP         # not
        YEET        # throw/raise
        LOWKEY      # try
        HIGHKEY     # catch/except
        DEADASS     # assert
        SEND        # yield
        FR          # import
        BESTIE      # from
        GHOST       # pass
        STAN        # module
        SHOOK       # using/import
        VIBECHECK   # include

        # Literals
        IDENTIFIER
        INTEGER
        FLOAT
        STRING
        BOOLEAN

        # Operators
        PLUS
        MINUS
        MULTIPLY
        DIVIDE
        MODULO
        POWER
        ASSIGN
        EQUAL
        NOTEQUAL
        LESSTHAN
        GREATERTHAN
        LTE
        GTE

        # Delimiters
        LPAREN      # (
        RPAREN      # )
        LBRACE      # {
        RBRACE      # }
        LBRACKET    # [
        RBRACKET    # ]
        COMMA
        SEMICOLON
        COLON
        DOT

        # Special
        NEWLINE
        WHITESPACE
        COMMENT
        ENDOFFILE
    end

    # Token struct
    mutable struct Token
        type::TokenType
        value::String
        line::Int
        column::Int
    end

    # Keyword mapping
    const KEYWORDS = Dict{String, TokenType}(
        "bussin" => BUSSIN,
        "bussd" => BUSSD,
        "no cap" => NOCAP,
        "slay" => SLAY,
        "let's go" => LETSGO,
        "periodt" => PERIODT,
        "sksksk" => SKSKSK,
        "drop" => DROP,
        "tea" => TEA,
        "main character" => MAINCHARACTER,
        "flex" => FLEX,
        "weak" => WEAK,
        "strong" => STRONG,
        "sus" => SUS,
        "fake" => FAKE,
        "based" => BASED,
        "crazy" => CRAZY,
        "cap" => CAP,
        "yeet" => YEET,
        "lowkey" => LOWKEY,
        "highkey" => HIGHKEY,
        "deadass" => DEADASS,
        "send" => SEND,
        "fr" => FR,
        "bestie" => BESTIE,
        "ghost" => GHOST,
        "stan" => STAN,
        "shook" => SHOOK,
        "vibe check" => VIBECHECK
    )

    """
    Tokenizes the input source code and returns an array of tokens
    """
    function tokenize(source::String)
        tokens = Token[]
        i = 1
        line = 1
        column = 1

        while i <= length(source)
            char = source[i]
            
            # Handle whitespace
            if isspace(char)
                if char == '\n'
                    push!(tokens, Token(NEWLINE, "\n", line, column))
                    line += 1
                    column = 1
                    i += 1  # Make sure to advance the index
                else
                    start_pos = i
                    while i <= length(source) && isspace(source[i]) && source[i] != '\n'
                        i += 1
                        column += 1
                    end
                end
                continue  # Continue to next character
            end
            
            # Handle identifiers and keywords
            start_col = column  # Capture starting column
            if isletter(char) || char == '_'
                # Look ahead to see if we have a multi-word keyword
                # We need to check if the current word and next word form a multi-word keyword
                possible_multi_word = ""
                end_pos = i
                word1_end = i
                # Find first word
                while end_pos <= length(source) && (isletter(source[end_pos]) || isdigit(source[end_pos]) || source[end_pos] == '_' || source[end_pos] == '\'')
                    end_pos += 1
                end
                word1 = source[i:end_pos-1]
                
                # Check if there's a space followed by another word
                if end_pos <= length(source) && source[end_pos] == ' '
                    # Look for the next word
                    next_pos = end_pos + 1
                    if next_pos <= length(source) && (isletter(source[next_pos]) || source[next_pos] == '_')
                        temp_pos = next_pos
                        while temp_pos <= length(source) && (isletter(source[temp_pos]) || isdigit(source[temp_pos]) || source[temp_pos] == '_' || source[temp_pos] == '\'')
                            temp_pos += 1
                        end
                        word2 = source[next_pos:temp_pos-1]
                        possible_multi_word = word1 * " " * word2
                        
                        # Check if this is a known multi-word keyword
                        if haskey(KEYWORDS, lowercase(possible_multi_word))
                            # Use the multi-word keyword
                            value = possible_multi_word
                            push!(tokens, Token(KEYWORDS[lowercase(value)], value, line, start_col))
                            i = temp_pos  # Move past both words
                            column = start_col + length(value)  # Update column
                            continue  # Continue with next character
                        end
                    end
                end
                
                # If no multi-word keyword, use single word
                value = word1
                i = end_pos
                column = start_col + length(value)
                
                if haskey(KEYWORDS, lowercase(value))
                    push!(tokens, Token(KEYWORDS[lowercase(value)], value, line, start_col))
                else
                    push!(tokens, Token(IDENTIFIER, value, line, start_col))
                end
                continue  # Continue with next character
            end
            
            # Handle numbers
            if isdigit(char)
                start_pos = i
                start_col = column
                
                while i <= length(source) && (isdigit(source[i]) || source[i] == '.')
                    i += 1
                    column += 1
                end
                
                value = source[start_pos:i-1]
                tok_type = occursin('.', value) ? FLOAT : INTEGER
                push!(tokens, Token(tok_type, value, line, start_col))
                continue
            end
            
            # Handle strings
            if char == '"' || char == '\''
                start_pos = i
                start_col = column
                quote_char = char
                i += 1  # Move past opening quote
                column += 1
                
                while i <= length(source) && source[i] != quote_char
                    if source[i] == '\\' && i + 1 <= length(source)
                        i += 2  # Skip escape sequence
                        column += 2
                    else
                        i += 1
                        column += 1
                    end
                end
                
                if i > length(source) || source[i] != quote_char
                    throw(ArgumentError("Unterminated string at line $line, column $column"))
                end
                
                i += 1  # Move past closing quote
                column += 1
                value = source[start_pos:i-1]
                push!(tokens, Token(STRING, value, line, start_col))
                continue
            end
            
            # Handle operators and delimiters
            if char == '='
                if i + 1 <= length(source) && source[i+1] == '='
                    push!(tokens, Token(EQUAL, "==", line, column))
                    i += 2
                    column += 2
                    continue
                else
                    push!(tokens, Token(ASSIGN, "=", line, column))
                    i += 1
                    column += 1
                    continue
                end
            end
            
            if char == '!'
                if i + 1 <= length(source) && source[i+1] == '='
                    push!(tokens, Token(NOTEQUAL, "!=", line, column))
                    i += 2
                    column += 2
                    continue
                else
                    i += 1  # Move past '!' if not part of '!='
                end
            end
            
            if char == '<'
                if i + 1 <= length(source) && source[i+1] == '='
                    push!(tokens, Token(LTE, "<=", line, column))
                    i += 2
                    column += 2
                    continue
                else
                    push!(tokens, Token(LESSTHAN, "<", line, column))
                    i += 1
                    column += 1
                    continue
                end
            end
            
            if char == '>'
                if i + 1 <= length(source) && source[i+1] == '='
                    push!(tokens, Token(GTE, ">=", line, column))
                    i += 2
                    column += 2
                    continue
                else
                    push!(tokens, Token(GREATERTHAN, ">", line, column))
                    i += 1
                    column += 1
                    continue
                end
            end
            
            if char == '+'
                push!(tokens, Token(PLUS, "+", line, column))
                i += 1
                column += 1
                continue
            elseif char == '-'
                push!(tokens, Token(MINUS, "-", line, column))
                i += 1
                column += 1
                continue
            elseif char == '*'
                if i + 1 <= length(source) && source[i+1] == '*'
                    push!(tokens, Token(POWER, "**", line, column))
                    i += 2
                    column += 2
                else
                    push!(tokens, Token(MULTIPLY, "*", line, column))
                    i += 1
                    column += 1
                end
                continue
            elseif char == '/'
                if i + 1 <= length(source) && source[i+1] == '/'
                    # Single-line comment
                    while i <= length(source) && source[i] != '\n'
                        i += 1
                        column += 1
                    end
                    # We don't add comments as tokens, just skip them
                    continue
                else
                    push!(tokens, Token(DIVIDE, "/", line, column))
                    i += 1
                    column += 1
                end
                continue
            elseif char == '%'
                push!(tokens, Token(MODULO, "%", line, column))
                i += 1
                column += 1
                continue
            end
            
            # Delimiters
            if char == '('
                push!(tokens, Token(LPAREN, "(", line, column))
                i += 1
                column += 1
                continue
            elseif char == ')'
                push!(tokens, Token(RPAREN, ")", line, column))
                i += 1
                column += 1
                continue
            elseif char == '{'
                push!(tokens, Token(LBRACE, "{", line, column))
                i += 1
                column += 1
                continue
            elseif char == '}'
                push!(tokens, Token(RBRACE, "}", line, column))
                i += 1
                column += 1
                continue
            elseif char == '['
                push!(tokens, Token(LBRACKET, "[", line, column))
                i += 1
                column += 1
                continue
            elseif char == ']'
                push!(tokens, Token(RBRACKET, "]", line, column))
                i += 1
                column += 1
                continue
            elseif char == ','
                push!(tokens, Token(COMMA, ",", line, column))
                i += 1
                column += 1
                continue
            elseif char == ';'
                push!(tokens, Token(SEMICOLON, ";", line, column))
                i += 1
                column += 1
                continue
            elseif char == ':'
                push!(tokens, Token(COLON, ":", line, column))
                i += 1
                column += 1
                continue
            elseif char == '.'
                push!(tokens, Token(DOT, ".", line, column))
                i += 1
                column += 1
                continue
            end
            
            # Handle comments (tea time)
            if i + 7 <= length(source) && source[i:i+7] == "tea time"
                # Skip the comment
                while i <= length(source) && source[i] != '\n'
                    i += 1
                    column += 1
                end
                continue
            end
            
            # If we get here, it's an invalid character
            throw(ArgumentError("Invalid character '$char' at line $line, column $column"))
        end
        
        push!(tokens, Token(ENDOFFILE, "", line, column))
        return tokens
    end
end  # Tokenizer module

# Parser module
module Parser
    using ..Tokenizer
    using ..AST

    """
    Parser for the slang language
    """
    mutable struct SlangParser
        tokens::Vector{Tokenizer.Token}
        current::Int
        current_token::Tokenizer.Token
        
        function SlangParser(tokens::Vector{Tokenizer.Token})
            parser = new(tokens, 1, tokens[1])
            return parser
        end
    end

    """
    Advance to the next token
    """
    function advance!(parser::SlangParser)
        if parser.current < length(parser.tokens)
            parser.current += 1
            parser.current_token = parser.tokens[parser.current]
        end
    end

    """
    Check if current token matches the expected type
    """
    function check(parser::SlangParser, token_type::Tokenizer.TokenType)
        return parser.current_token.type == token_type
    end

    """
    Match the current token type and advance if it matches
    """
    function match!(parser::SlangParser, token_type::Tokenizer.TokenType)
        if check(parser, token_type)
            advance!(parser)
            return true
        end
        return false
    end

    """
    Expect a specific token type, throw error if not found
    """
    function expect!(parser::SlangParser, token_type::Tokenizer.TokenType)
        if !check(parser, token_type)
            throw(ArgumentError("Expected $(token_type), got $(parser.current_token.type)"))
        end
        advance!(parser)
    end

    """
    Parse a complete program
    """
    function parse_program(parser::SlangParser)
        statements = AST.Statement[]
        
        # Skip newlines between statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        while !check(parser, Tokenizer.ENDOFFILE)
            if check(parser, Tokenizer.ENDOFFILE)
                break
            end
            
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(statements, stmt)
            end
            
            # Skip newlines between statements
            while match!(parser, Tokenizer.NEWLINE)
            end
        end
        
        return AST.Program(statements)
    end

    """
    Parse a statement
    """
    function parse_statement(parser::SlangParser)
        # Handle different statement types based on the first token
        if check(parser, Tokenizer.DROP)  # drop (function)
            return parse_function_definition(parser)
        elseif check(parser, Tokenizer.MAINCHARACTER)  # main character (class)
            return parse_class_definition(parser)
        elseif check(parser, Tokenizer.STAN)  # stan (module)
            return parse_module_definition(parser)
        elseif check(parser, Tokenizer.BUSSIN)  # bussin (if)
            return parse_if_statement(parser)
        elseif check(parser, Tokenizer.SLAY)  # slay (while)
            return parse_while_statement(parser)
        elseif check(parser, Tokenizer.LETSGO)  # let's go (for)
            return parse_for_statement(parser)
        elseif check(parser, Tokenizer.LOWKEY)  # lowkey (try)
            return parse_try_statement(parser)
        elseif check(parser, Tokenizer.DEADASS)  # deadass (assert)
            return parse_assert_statement(parser)
        elseif check(parser, Tokenizer.YEET)  # yeet (throw/raise)
            return parse_raise_statement(parser)
        elseif check(parser, Tokenizer.FR)  # fr (import)
            return parse_import_statement(parser)
        elseif check(parser, Tokenizer.PERIODT)  # periodt (break)
            advance!(parser)  # consume 'periodt'
            return AST.BreakStmt()
        elseif check(parser, Tokenizer.SKSKSK)  # sksksk (continue)
            advance!(parser)  # consume 'sksksk'
            return AST.ContinueStmt()
        elseif check(parser, Tokenizer.TEA)  # tea (return)
            advance!(parser)  # consume 'tea'
            expr = nothing
            if !check(parser, Tokenizer.NEWLINE) && !check(parser, Tokenizer.ENDOFFILE)
                expr = parse_expression(parser)
            end
            return AST.ReturnStmt(expr)
        elseif check(parser, Tokenizer.GHOST)  # ghost (pass)
            advance!(parser)  # consume 'ghost'
            return AST.PassStmt()
        elseif check(parser, Tokenizer.WEAK)  # weak variable declaration
            advance!(parser)  # consume 'weak'
            target = parser.current_token  # get the identifier token
            expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
            expect!(parser, Tokenizer.ASSIGN)  # expect '=' and advance
            value = parse_expression(parser)
            target_expr = AST.Identifier(target.value)
            return AST.AssignmentStmt(target_expr, value)
        elseif check(parser, Tokenizer.STRONG)  # strong variable declaration
            advance!(parser)  # consume 'strong'
            target = parser.current_token  # get the identifier token
            expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
            expect!(parser, Tokenizer.ASSIGN)  # expect '=' and advance
            value = parse_expression(parser)
            target_expr = AST.Identifier(target.value)
            return AST.AssignmentStmt(target_expr, value)
        else
            # Handle assignment or expression statement
            expr = parse_expression(parser)
            
            # Check if this is an assignment (for cases without 'weak')
            if match!(parser, Tokenizer.ASSIGN)
                value = parse_expression(parser)
                return AST.AssignmentStmt(expr, value)
            end
            
            # Otherwise it's just an expression statement
            return AST.ExpressionStmt(expr)
        end
    end

    """
    Parse a function definition
    """
    function parse_function_definition(parser::SlangParser)
        expect!(parser, Tokenizer.DROP)  # consume 'drop'
        
        name = parser.current_token  # get the identifier token
        expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
        expect!(parser, Tokenizer.LPAREN)  # consume '('
        
        parameters = []
        if !check(parser, Tokenizer.RPAREN)
            push!(parameters, parse_parameter(parser))
            while match!(parser, Tokenizer.COMMA)
                push!(parameters, parse_parameter(parser))
            end
        end
        expect!(parser, Tokenizer.RPAREN)  # consume ')'
        
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse function body (list of statements)
        body = []
        while !check(parser, Tokenizer.ENDOFFILE) && !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        return AST.FunctionDef(name.value, parameters, body)
    end

    """
    Parse a parameter in function definition
    """
    function parse_parameter(parser::SlangParser)
        name = parser.current_token  # get the identifier token
        expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
        return name.value
    end

    """
    Parse a class definition
    """
    function parse_class_definition(parser::SlangParser)
        expect!(parser, Tokenizer.MAINCHARACTER)  # consume 'main character'
        
        name = parser.current_token  # get the identifier token
        expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse class body (list of statements)
        body = []
        while !check(parser, Tokenizer.ENDOFFILE) && !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        return AST.ClassDef(name.value, body)
    end

    """
    Parse a module definition
    """
    function parse_module_definition(parser::SlangParser)
        expect!(parser, Tokenizer.STAN)  # consume 'stan'
        
        name = parser.current_token  # get the identifier token
        expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse module body (list of statements)
        body = []
        while !check(parser, Tokenizer.ENDOFFILE) && !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        return AST.ModuleDef(name.value, body)
    end

    """
    Parse an if statement
    """
    function parse_if_statement(parser::SlangParser)
        expect!(parser, Tokenizer.BUSSIN)  # consume 'bussin'
        
        condition = parse_expression(parser)
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse if body (list of statements)
        if_body = []
        while !check(parser, Tokenizer.ENDOFFILE) && 
              !check(parser, Tokenizer.BUSSD) && 
              !check(parser, Tokenizer.NOCAP) &&
              !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(if_body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        # Check for elif clauses
        elif_clauses = []
        while check(parser, Tokenizer.BUSSD)
            expect!(parser, Tokenizer.BUSSD)  # consume 'bussd'
            elif_condition = parse_expression(parser)
            expect!(parser, Tokenizer.COLON)  # consume ':'
            
            # Parse elif body
            elif_body = []
            while !check(parser, Tokenizer.ENDOFFILE) && 
                  !check(parser, Tokenizer.BUSSD) && 
                  !check(parser, Tokenizer.NOCAP) &&
                  !check(parser, Tokenizer.NEWLINE)
                stmt = parse_statement(parser)
                if stmt !== nothing
                    push!(elif_body, stmt)
                end
            end
            
            # Skip newlines after statements
            while match!(parser, Tokenizer.NEWLINE)
            end
            
            push!(elif_clauses, (elif_condition, elif_body))
        end
        
        # Check for else clause
        else_body = nothing
        if match!(parser, Tokenizer.NOCAP)  # consume 'no cap'
            expect!(parser, Tokenizer.COLON)  # consume ':'
            
            # Parse else body
            else_body = []
            while !check(parser, Tokenizer.ENDOFFILE) && 
                  !check(parser, Tokenizer.BUSSD) && 
                  !check(parser, Tokenizer.NOCAP) &&
                  !check(parser, Tokenizer.NEWLINE)
                stmt = parse_statement(parser)
                if stmt !== nothing
                    push!(else_body, stmt)
                end
            end
            
            # Skip newlines after statements
            while match!(parser, Tokenizer.NEWLINE)
            end
        end
        
        return AST.IfStmt(condition, if_body, elif_clauses, else_body)
    end

    """
    Parse a while statement
    """
    function parse_while_statement(parser::SlangParser)
        expect!(parser, Tokenizer.SLAY)  # consume 'slay'
        
        condition = parse_expression(parser)
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse while body (list of statements)
        body = []
        while !check(parser, Tokenizer.ENDOFFILE) && 
              !check(parser, Tokenizer.BUSSIN) && 
              !check(parser, Tokenizer.SLAY) && 
              !check(parser, Tokenizer.LETSGO) && 
              !check(parser, Tokenizer.DROP) && 
              !check(parser, Tokenizer.PERIODT) &&
              !check(parser, Tokenizer.SKSKSK) &&
              !check(parser, Tokenizer.TEA) &&
              !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        return AST.WhileStmt(condition, body)
    end

    """
    Parse a for statement
    """
    function parse_for_statement(parser::SlangParser)
        expect!(parser, Tokenizer.LETSGO)  # consume "let's go"
        
        variable = parser.current_token  # get the identifier token
        expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
        # In the slang language, we'll use "based" to mean "in" for the for loop
        expect!(parser, Tokenizer.BASED)  # consume 'based' (meaning 'in')
        
        iterable = parse_expression(parser)
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse for body (list of statements)
        body = []
        while !check(parser, Tokenizer.ENDOFFILE) &&
              !check(parser, Tokenizer.BUSSIN) && 
              !check(parser, Tokenizer.SLAY) && 
              !check(parser, Tokenizer.LETSGO) && 
              !check(parser, Tokenizer.DROP) && 
              !check(parser, Tokenizer.PERIODT) &&
              !check(parser, Tokenizer.SKSKSK) &&
              !check(parser, Tokenizer.TEA) &&
              !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        return AST.ForStmt(variable.value, iterable, body)
    end

    """
    Parse a try statement
    """
    function parse_try_statement(parser::SlangParser)
        expect!(parser, Tokenizer.LOWKEY)  # consume 'lowkey'
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse try body (list of statements)
        try_body = []
        while !check(parser, Tokenizer.ENDOFFILE) && 
              !check(parser, Tokenizer.HIGHKEY) &&
              !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(try_body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        # Parse catch/except block
        expect!(parser, Tokenizer.HIGHKEY)  # consume 'highkey'
        expect!(parser, Tokenizer.COLON)  # consume ':'
        
        # Parse except body (list of statements)
        except_body = []
        while !check(parser, Tokenizer.ENDOFFILE) && !check(parser, Tokenizer.NEWLINE)
            stmt = parse_statement(parser)
            if stmt !== nothing
                push!(except_body, stmt)
            end
        end
        
        # Skip newlines after statements
        while match!(parser, Tokenizer.NEWLINE)
        end
        
        return AST.TryStmt(try_body, except_body)
    end

    """
    Parse an assert statement
    """
    function parse_assert_statement(parser::SlangParser)
        expect!(parser, Tokenizer.DEADASS)  # consume 'deadass'
        
        condition = parse_expression(parser)
        return AST.AssertStmt(condition)
    end

    """
    Parse a raise statement
    """
    function parse_raise_statement(parser::SlangParser)
        expect!(parser, Tokenizer.YEET)  # consume 'yeet'
        
        expr = parse_expression(parser)
        return AST.RaiseStmt(expr)
    end

    """
    Parse an import statement
    """
    function parse_import_statement(parser::SlangParser)
        expect!(parser, Tokenizer.FR)  # consume 'fr'
        
        module_name = parser.current_token  # get the identifier token
        expect!(parser, Tokenizer.IDENTIFIER)  # verify it's an identifier and advance
        return AST.ImportStmt(module_name.value)
    end

    """
    Parse an expression (top level of expression precedence)
    """
    function parse_expression(parser::SlangParser)
        return parse_logical_or(parser)
    end

    """
    Parse logical OR expression
    """
    function parse_logical_or(parser::SlangParser)
        left = parse_logical_and(parser)
        
        while check(parser, Tokenizer.CRAZY)  # crazy (or)
            op_token = parser.current_token
            advance!(parser)  # consume 'crazy'
            right = parse_logical_and(parser)
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse logical AND expression
    """
    function parse_logical_and(parser::SlangParser)
        left = parse_equality(parser)
        
        while check(parser, Tokenizer.BASED)  # based (and)
            op_token = parser.current_token
            advance!(parser)  # consume 'based'
            right = parse_equality(parser)
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse equality expression
    """
    function parse_equality(parser::SlangParser)
        left = parse_comparison(parser)
        
        while check(parser, Tokenizer.EQUAL) || check(parser, Tokenizer.NOTEQUAL)
            op_token = parser.current_token
            advance!(parser)
            right = parse_comparison(parser)
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse comparison expression
    """
    function parse_comparison(parser::SlangParser)
        left = parse_addition(parser)
        
        while (check(parser, Tokenizer.LESSTHAN) || 
               check(parser, Tokenizer.GREATERTHAN) || 
               check(parser, Tokenizer.LTE) || 
               check(parser, Tokenizer.GTE))
            op_token = parser.current_token
            advance!(parser)
            right = parse_addition(parser)
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse addition/subtraction expression
    """
    function parse_addition(parser::SlangParser)
        left = parse_multiplication(parser)
        
        while check(parser, Tokenizer.PLUS) || check(parser, Tokenizer.MINUS)
            op_token = parser.current_token
            advance!(parser)
            right = parse_multiplication(parser)
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse multiplication/division expression
    """
    function parse_multiplication(parser::SlangParser)
        left = parse_power(parser)
        
        while check(parser, Tokenizer.MULTIPLY) || 
              check(parser, Tokenizer.DIVIDE) || 
              check(parser, Tokenizer.MODULO)
            op_token = parser.current_token
            advance!(parser)
            right = parse_power(parser)
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse exponentiation expression
    """
    function parse_power(parser::SlangParser)
        left = parse_unary(parser)
        
        if check(parser, Tokenizer.POWER)  # **
            op_token = parser.current_token
            advance!(parser)
            right = parse_power(parser)  # Right associative
            left = AST.BinaryOp(left, op_token.value, right)
        end
        
        return left
    end

    """
    Parse unary expression (not, -, +)
    """
    function parse_unary(parser::SlangParser)
        if check(parser, Tokenizer.CAP)  # cap (not)
            op_token = parser.current_token
            advance!(parser)
            operand = parse_unary(parser)
            return AST.UnaryOp(op_token.value, operand)
        elseif check(parser, Tokenizer.MINUS)
            op_token = parser.current_token
            advance!(parser)
            operand = parse_unary(parser)
            return AST.UnaryOp(op_token.value, operand)
        elseif check(parser, Tokenizer.PLUS)
            op_token = parser.current_token
            advance!(parser)
            operand = parse_unary(parser)
            return AST.UnaryOp(op_token.value, operand)
        end
        
        return parse_primary(parser)
    end

    """
    Parse primary expressions (literals, identifiers, parenthesized expressions)
    """
    function parse_primary(parser::SlangParser)
        if check(parser, Tokenizer.INTEGER)
            token = parser.current_token
            advance!(parser)
            return AST.Literal(parse(Int, token.value))
        elseif check(parser, Tokenizer.FLOAT)
            token = parser.current_token
            advance!(parser)
            return AST.Literal(parse(Float64, token.value))
        elseif check(parser, Tokenizer.STRING)
            token = parser.current_token
            advance!(parser)
            # Remove quotes from string literal
            value = token.value[2:end-1]  # Remove first and last character (quotes)
            return AST.Literal(value)
        elseif check(parser, Tokenizer.SUS) || check(parser, Tokenizer.FAKE)  # sus/fake (True/False)
            token = parser.current_token
            advance!(parser)
            value = (token.type == Tokenizer.SUS) ? true : false
            return AST.Literal(value)
        elseif check(parser, Tokenizer.IDENTIFIER)
            token = parser.current_token
            advance!(parser)
            # Check if it's a function call
            if check(parser, Tokenizer.LPAREN)
                return parse_function_call(parser, token.value)
            end
            return AST.Identifier(token.value)
        elseif check(parser, Tokenizer.LPAREN)  # Parenthesized expression
            advance!(parser)  # consume '('
            expr = parse_expression(parser)
            expect!(parser, Tokenizer.RPAREN)  # consume ')'
            return expr
        else
            throw(ArgumentError("Unexpected token $(parser.current_token.type)"))
        end
    end

    """
    Parse a function call
    """
    function parse_function_call(parser::SlangParser, func_name::String)
        expect!(parser, Tokenizer.LPAREN)  # consume '('
        
        arguments = []
        if !check(parser, Tokenizer.RPAREN)
            push!(arguments, parse_expression(parser))
            while match!(parser, Tokenizer.COMMA)
                push!(arguments, parse_expression(parser))
            end
        end
        expect!(parser, Tokenizer.RPAREN)  # consume ')'
        
        return AST.Call(func_name, arguments)
    end

end  # Parser module

# Semantic Analyzer module
module SemanticAnalyzer
    using ..AST

    # Symbol table for tracking variables, functions, etc.
    mutable struct SymbolTable
        symbols::Dict{String, Any}
        parent::Union{SymbolTable, Nothing}
        
        SymbolTable(parent::Union{SymbolTable, Nothing}=nothing) = new(Dict{String, Any}(), parent)
    end

    # Add a symbol to the table
    function add_symbol!(table::SymbolTable, name::String, value)
        table.symbols[name] = value
    end

    # Look up a symbol in the current or parent scopes
    function lookup_symbol(table::SymbolTable, name::String)
        current_table = table
        while current_table !== nothing
            if haskey(current_table.symbols, name)
                return current_table.symbols[name]
            end
            current_table = current_table.parent
        end
        return nothing
    end

    # Semantic analysis context
    mutable struct SemanticContext
        symbol_table::SymbolTable
        errors::Vector{String}
        current_function::Union{String, Nothing}
        function_defs::Dict{String, AST.FunctionDef}
        
        SemanticContext() = new(SymbolTable(), String[], nothing, Dict{String, AST.FunctionDef}())
    end

    """
    Perform semantic analysis on the AST
    """
    function analyze(ast::AST.Program, context::SemanticContext=SemanticContext())
        for stmt in ast.statements
            analyze_statement(stmt, context)
        end
        return context.errors
    end

    """
    Analyze a statement
    """
    function analyze_statement(stmt::AST.Statement, context::SemanticContext)
        if isa(stmt, AST.FunctionDef)
            analyze_function_definition(stmt, context)
        elseif isa(stmt, AST.ClassDef)
            analyze_class_definition(stmt, context)
        elseif isa(stmt, AST.IfStmt)
            analyze_if_statement(stmt, context)
        elseif isa(stmt, AST.WhileStmt)
            analyze_while_statement(stmt, context)
        elseif isa(stmt, AST.ForStmt)
            analyze_for_statement(stmt, context)
        elseif isa(stmt, AST.TryStmt)
            analyze_try_statement(stmt, context)
        elseif isa(stmt, AST.AssignmentStmt)
            analyze_assignment(stmt, context)
        elseif isa(stmt, AST.ReturnStmt)
            analyze_return_statement(stmt, context)
        elseif isa(stmt, AST.ExpressionStmt)
            analyze_expression(stmt.expression, context)
        elseif isa(stmt, AST.ImportStmt)
            analyze_import_statement(stmt, context)
        elseif isa(stmt, AST.AssertStmt)
            analyze_assert_statement(stmt, context)
        elseif isa(stmt, AST.RaiseStmt)
            analyze_raise_statement(stmt, context)
        elseif isa(stmt, AST.BreakStmt) || isa(stmt, AST.ContinueStmt) || isa(stmt, AST.PassStmt)
            # These statements don't require semantic analysis
        else
            push!(context.errors, "Unknown statement type: $(typeof(stmt))")
        end
    end

    """
    Analyze a function definition
    """
    function analyze_function_definition(func_def::AST.FunctionDef, context::SemanticContext)
        # Add function to function definitions
        context.function_defs[func_def.name] = func_def
        
        # Add function to symbol table
        add_symbol!(context.symbol_table, func_def.name, :function)
        
        # Create new scope for function body
        func_scope = SymbolTable(context.symbol_table)
        
        # Add parameters to function scope
        for param in func_def.parameters
            add_symbol!(func_scope, param, :parameter)
        end
        
        # Save current function and set to new function
        old_function = context.current_function
        context.current_function = func_def.name
        
        # Analyze function body in the new scope
        old_symbol_table = context.symbol_table
        context.symbol_table = func_scope
        
        for stmt in func_def.body
            analyze_statement(stmt, context)
        end
        
        # Restore previous scope and function
        context.symbol_table = old_symbol_table
        context.current_function = old_function
    end

    """
    Analyze a class definition
    """
    function analyze_class_definition(class_def::AST.ClassDef, context::SemanticContext)
        # Add class to symbol table
        add_symbol!(context.symbol_table, class_def.name, :class)
        
        # Create new scope for class body
        class_scope = SymbolTable(context.symbol_table)
        
        # Analyze class body in the new scope
        old_symbol_table = context.symbol_table
        context.symbol_table = class_scope
        
        for stmt in class_def.body
            analyze_statement(stmt, context)
        end
        
        # Restore previous scope
        context.symbol_table = old_symbol_table
    end

    """
    Analyze an if statement
    """
    function analyze_if_statement(if_stmt::AST.IfStmt, context::SemanticContext)
        # Analyze condition
        analyze_expression(if_stmt.condition, context)
        
        # Analyze if body
        old_symbol_table = context.symbol_table
        if_scope = SymbolTable(context.symbol_table)
        context.symbol_table = if_scope
        
        for stmt in if_stmt.if_body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
        
        # Analyze elif clauses
        for (condition, body) in if_stmt.elif_clauses
            analyze_expression(condition, context)
            
            elif_scope = SymbolTable(context.symbol_table)
            context.symbol_table = elif_scope
            for stmt in body
                analyze_statement(stmt, context)
            end
            context.symbol_table = old_symbol_table
        end
        
        # Analyze else body if it exists
        if if_stmt.else_body !== nothing
            else_scope = SymbolTable(context.symbol_table)
            context.symbol_table = else_scope
            for stmt in if_stmt.else_body
                analyze_statement(stmt, context)
            end
            context.symbol_table = old_symbol_table
        end
    end

    """
    Analyze a while statement
    """
    function analyze_while_statement(while_stmt::AST.WhileStmt, context::SemanticContext)
        # Analyze condition
        analyze_expression(while_stmt.condition, context)
        
        # Analyze body
        old_symbol_table = context.symbol_table
        while_scope = SymbolTable(context.symbol_table)
        context.symbol_table = while_scope
        
        for stmt in while_stmt.body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
    end

    """
    Analyze a for statement
    """
    function analyze_for_statement(for_stmt::AST.ForStmt, context::SemanticContext)
        # Analyze iterable
        analyze_expression(for_stmt.iterable, context)
        
        # Add loop variable to scope
        add_symbol!(context.symbol_table, for_stmt.variable, :loop_variable)
        
        # Analyze body
        old_symbol_table = context.symbol_table
        for_scope = SymbolTable(context.symbol_table)
        add_symbol!(for_scope, for_stmt.variable, :loop_variable)
        context.symbol_table = for_scope
        
        for stmt in for_stmt.body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
    end

    """
    Analyze a try statement
    """
    function analyze_try_statement(try_stmt::AST.TryStmt, context::SemanticContext)
        # Analyze try body
        old_symbol_table = context.symbol_table
        try_scope = SymbolTable(context.symbol_table)
        context.symbol_table = try_scope
        
        for stmt in try_stmt.try_body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
        
        # Analyze except body
        except_scope = SymbolTable(context.symbol_table)
        context.symbol_table = except_scope
        
        for stmt in try_stmt.except_body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
    end

    """
    Analyze an assignment statement
    """
    function analyze_assignment(assignment::AST.AssignmentStmt, context::SemanticContext)
        # Analyze the value being assigned
        analyze_expression(assignment.value, context)
        
        # For now, just add the variable to symbol table
        # In a more complete implementation, we'd check if the target is valid
        if isa(assignment.target, AST.Identifier)
            add_symbol!(context.symbol_table, assignment.target.name, :variable)
        end
    end

    """
    Analyze a return statement
    """
    function analyze_return_statement(return_stmt::AST.ReturnStmt, context::SemanticContext)
        if return_stmt.value !== nothing
            analyze_expression(return_stmt.value, context)
        end
        
        # Check if return is inside a function
        if context.current_function === nothing
            push!(context.errors, "Return statement outside function at $(return_stmt)")
        end
    end

    """
    Analyze an import statement
    """
    function analyze_import_statement(import_stmt::AST.ImportStmt, context::SemanticContext)
        # For now, just record the import
        add_symbol!(context.symbol_table, import_stmt.module_name, :imported_module)
    end

    """
    Analyze an assert statement
    """
    function analyze_assert_statement(assert_stmt::AST.AssertStmt, context::SemanticContext)
        # Analyze the assertion condition
        analyze_expression(assert_stmt.condition, context)
    end

    """
    Analyze a raise statement
    """
    function analyze_raise_statement(raise_stmt::AST.RaiseStmt, context::SemanticContext)
        # Analyze the expression being raised
        analyze_expression(raise_stmt.expression, context)
    end

    """
    Analyze an expression
    """
    function analyze_expression(expr::AST.Expression, context::SemanticContext)
        if isa(expr, AST.Literal)
            # Literals don't need semantic analysis
        elseif isa(expr, AST.Identifier)
            # Check if identifier is defined in current or parent scopes
            if lookup_symbol(context.symbol_table, expr.name) === nothing
                push!(context.errors, "Undefined variable: $(expr.name)")
            end
        elseif isa(expr, AST.BinaryOp)
            analyze_expression(expr.left, context)
            analyze_expression(expr.right, context)
        elseif isa(expr, AST.UnaryOp)
            analyze_expression(expr.operand, context)
        elseif isa(expr, AST.Call)
            analyze_call(expr, context)
        else
            push!(context.errors, "Unknown expression type: $(typeof(expr))")
        end
    end

    """
    Analyze a function call
    """
    function analyze_call(call::AST.Call, context::SemanticContext)
        # Check if function is defined
        if lookup_symbol(context.symbol_table, call.func) === nothing
            if !haskey(context.function_defs, call.func)
                push!(context.errors, "Undefined function: $(call.func)")
            end
        end
        
        # Analyze arguments
        for arg in call.args
            analyze_expression(arg, context)
        end
    end

end  # SemanticAnalyzer module

# Code Generator module
module CodeGenerator
    using ..AST

    """
    Code generator that translates slang AST to Julia code
    """
    mutable struct CodeGenContext
        output::IOBuffer
        indent_level::Int
        variable_counter::Int
        
        CodeGenContext() = new(IOBuffer(), 0, 0)
    end

    """
    Generate Julia code from the AST program
    """
    function generate_code(ast::AST.Program, context::CodeGenContext=CodeGenContext())
        for stmt in ast.statements
            generate_statement(stmt, context)
        end
        return String(take!(context.output))
    end

    """
    Write with proper indentation
    """
    function write_indented(context::CodeGenContext, str::String)
        write(context.output, repeat("    ", context.indent_level))
        write(context.output, str)
    end

    """
    Increase indentation level
    """
    function indent!(context::CodeGenContext)
        context.indent_level += 1
    end

    """
    Decrease indentation level
    """
    function unindent!(context::CodeGenContext)
        context.indent_level -= 1
    end

    """
    Generate code for a statement
    """
    function generate_statement(stmt::AST.Statement, context::CodeGenContext)
        if isa(stmt, AST.FunctionDef)
            generate_function_definition(stmt, context)
        elseif isa(stmt, AST.ClassDef)
            generate_class_definition(stmt, context)
        elseif isa(stmt, AST.ModuleDef)
            generate_module_definition(stmt, context)
        elseif isa(stmt, AST.IfStmt)
            generate_if_statement(stmt, context)
        elseif isa(stmt, AST.WhileStmt)
            generate_while_statement(stmt, context)
        elseif isa(stmt, AST.ForStmt)
            generate_for_statement(stmt, context)
        elseif isa(stmt, AST.TryStmt)
            generate_try_statement(stmt, context)
        elseif isa(stmt, AST.AssignmentStmt)
            generate_assignment(stmt, context)
        elseif isa(stmt, AST.ReturnStmt)
            generate_return_statement(stmt, context)
        elseif isa(stmt, AST.BreakStmt)
            generate_break_statement(stmt, context)
        elseif isa(stmt, AST.ContinueStmt)
            generate_continue_statement(stmt, context)
        elseif isa(stmt, AST.ExpressionStmt)
            generate_expression(stmt.expression, context)
            write(context.output, "\n")
        elseif isa(stmt, AST.ImportStmt)
            generate_import_statement(stmt, context)
        elseif isa(stmt, AST.AssertStmt)
            generate_assert_statement(stmt, context)
        elseif isa(stmt, AST.RaiseStmt)
            generate_raise_statement(stmt, context)
        elseif isa(stmt, AST.PassStmt)
            # Pass statement is just a comment in Julia
            write_indented(context, "# pass\n")
        else
            write_indented(context, "# Unknown statement: $(typeof(stmt))\n")
        end
    end

    """
    Generate code for a function definition
    """
    function generate_function_definition(func_def::AST.FunctionDef, context::CodeGenContext)
        write_indented(context, "function $(func_def.name)(")
        for (i, param) in enumerate(func_def.parameters)
            write(context.output, param)
            if i < length(func_def.parameters)
                write(context.output, ", ")
            end
        end
        write(context.output, ")\n")
        
        indent!()
        for stmt in func_def.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a class definition (converts to Julia mutable struct)
    """
    function generate_class_definition(class_def::AST.ClassDef, context::CodeGenContext)
        write_indented(context, "mutable struct $(class_def.name)\n")
        
        indent!()
        # For now, we'll just add a placeholder - in a real implementation,
        # we'd need to analyze the class body to determine fields
        write_indented(context, "# Fields would be determined from class body\n")
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a module definition
    """
    function generate_module_definition(module_def::AST.ModuleDef, context::CodeGenContext)
        write_indented(context, "module $(module_def.name)\n")
        
        indent!()
        for stmt in module_def.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for an if statement
    """
    function generate_if_statement(if_stmt::AST.IfStmt, context::CodeGenContext)
        write_indented(context, "if ")
        generate_expression(if_stmt.condition, context)
        write(context.output, "\n")
        
        indent!()
        for stmt in if_stmt.if_body
            generate_statement(stmt, context)
        end
        unindent!()
        
        # Generate elif clauses
        for (condition, body) in if_stmt.elif_clauses
            write_indented(context, "elseif ")
            generate_expression(condition, context)
            write(context.output, "\n")
            
            indent!()
            for stmt in body
                generate_statement(stmt, context)
            end
            unindent!()
        end
        
        # Generate else clause if it exists
        if if_stmt.else_body !== nothing
            write_indented(context, "else\n")
            
            indent!()
            for stmt in if_stmt.else_body
                generate_statement(stmt, context)
            end
            unindent!()
        end
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a while statement
    """
    function generate_while_statement(while_stmt::AST.WhileStmt, context::CodeGenContext)
        write_indented(context, "while ")
        generate_expression(while_stmt.condition, context)
        write(context.output, "\n")
        
        indent!()
        for stmt in while_stmt.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a for statement
    """
    function generate_for_statement(for_stmt::AST.ForStmt, context::CodeGenContext)
        write_indented(context, "for $(for_stmt.variable) in ")
        generate_expression(for_stmt.iterable, context)
        write(context.output, "\n")
        
        indent!()
        for stmt in for_stmt.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a try statement
    """
    function generate_try_statement(try_stmt::AST.TryStmt, context::CodeGenContext)
        write_indented(context, "try\n")
        
        indent!()
        for stmt in try_stmt.try_body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "catch\n")
        
        indent!()
        for stmt in try_stmt.except_body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for an assignment statement
    """
    function generate_assignment(assignment::AST.AssignmentStmt, context::CodeGenContext)
        generate_expression(assignment.target, context)
        write(context.output, " = ")
        generate_expression(assignment.value, context)
        write(context.output, "\n")
    end

    """
    Generate code for a return statement
    """
    function generate_return_statement(return_stmt::AST.ReturnStmt, context::CodeGenContext)
        write_indented(context, "return")
        if return_stmt.value !== nothing
            write(context.output, " ")
            generate_expression(return_stmt.value, context)
        end
        write(context.output, "\n")
    end

    """
    Generate code for a break statement
    """
    function generate_break_statement(break_stmt::AST.BreakStmt, context::CodeGenContext)
        write_indented(context, "break\n")
    end

    """
    Generate code for a continue statement
    """
    function generate_continue_statement(continue_stmt::AST.ContinueStmt, context::CodeGenContext)
        write_indented(context, "continue\n")
    end

    """
    Generate code for an import statement
    """
    function generate_import_statement(import_stmt::AST.ImportStmt, context::CodeGenContext)
        write_indented(context, "import $(import_stmt.module_name)\n")
    end

    """
    Generate code for an assert statement
    """
    function generate_assert_statement(assert_stmt::AST.AssertStmt, context::CodeGenContext)
        write_indented(context, "Base.@assert ")
        generate_expression(assert_stmt.condition, context)
        write(context.output, "\n")
    end

    """
    Generate code for a raise statement
    """
    function generate_raise_statement(raise_stmt::AST.RaiseStmt, context::CodeGenContext)
        write_indented(context, "throw(")
        generate_expression(raise_stmt.expression, context)
        write(context.output, ")\n")
    end

    """
    Generate code for an expression
    """
    function generate_expression(expr::AST.Expression, context::CodeGenContext)
        if isa(expr, AST.Literal)
            if isa(expr.value, String)
                write(context.output, "\"$(expr.value)\"")
            elseif isa(expr.value, Bool)
                write(context.output, expr.value ? "true" : "false")
            else
                write(context.output, string(expr.value))
            end
        elseif isa(expr, AST.Identifier)
            write(context.output, expr.name)
        elseif isa(expr, AST.BinaryOp)
            generate_binary_op(expr, context)
        elseif isa(expr, AST.UnaryOp)
            generate_unary_op(expr, context)
        elseif isa(expr, AST.Call)
            generate_call(expr, context)
        else
            write(context.output, "# Unknown expression: $(typeof(expr))")
        end
    end

    """
    Generate code for a binary operation
    """
    function generate_binary_op(bin_op::AST.BinaryOp, context::CodeGenContext)
        write(context.output, "(")
        generate_expression(bin_op.left, context)
        
        # Map slang operators to Julia operators
        julia_op = map_slang_op_to_julia(bin_op.op)
        write(context.output, " $julia_op ")
        
        generate_expression(bin_op.right, context)
        write(context.output, ")")
    end

    """
    Map slang operators to Julia operators
    """
    function map_slang_op_to_julia(slang_op::String)
        op_mapping = Dict(
            "based" => "&&",    # and
            "crazy" => "||",    # or
            "cap" => "!=",      # not (this is wrong - 'cap' is negation, not inequality)
            "==" => "==",
            "!=" => "!=",
            "<" => "<",
            ">" => ">",
            "<=" => "<=",
            ">=" => ">=",
            "+" => "+",
            "-" => "-",
            "*" => "*",
            "/" => "/",
            "%" => "%",
            "**" => "^"         # exponentiation
        )
        
        # Special handling for 'cap' which means 'not' in slang but is used for inequality in some contexts
        if slang_op == "cap"
            # This is handled in unary ops, so we shouldn't reach here for 'cap'
            # unless there's an error in the parser
            return "!"  # logical NOT
        end
        
        return get(op_mapping, slang_op, slang_op)
    end

    """
    Generate code for a unary operation
    """
    function generate_unary_op(un_op::AST.UnaryOp, context::CodeGenContext)
        julia_op = un_op.op == "cap" ? "!" : un_op.op  # 'cap' means 'not'
        write(context.output, "($julia_op ")
        generate_expression(un_op.operand, context)
        write(context.output, ")")
    end

    """
    Generate code for a function call
    """
    function generate_call(call::AST.Call, context::CodeGenContext)
        write(context.output, call.func)
        write(context.output, "(")
        for (i, arg) in enumerate(call.args)
            generate_expression(arg, context)
            if i < length(call.args)
                write(context.output, ", ")
            end
        end
        write(context.output, ")")
    end

end  # CodeGenerator module

# Main compiler functions
using .AST
using .Tokenizer
using .Parser
using .SemanticAnalyzer
using .CodeGenerator

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

"""
Compile slang code from a file
"""
function compile_file(file_path::String)
    source_code = read(file_path, String)
    return compile(source_code)
end

"""
Compile and execute slang code from a file
"""
function run_file(file_path::String)
    source_code = read(file_path, String)
    return compile_and_execute(source_code)
end

end  # module