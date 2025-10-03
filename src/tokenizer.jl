# tokenizer.jl - Tokenizer for SlangLang

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