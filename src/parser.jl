# parser.jl - Parser for SlangLang

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