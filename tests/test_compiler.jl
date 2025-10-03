module TestSlangLang

using Test
include("../SlangLang.jl")
using .SlangLang

@testset "SlangLang Compiler Tests" begin
    
    @testset "Tokenizer Tests" begin
        # Test basic keyword tokenization
        source = "bussin sus:"
        tokens = SlangLang.Tokenizer.tokenize(source)
        @test length(tokens) >= 3  # bussin, sus, :
        @test tokens[1].type == SlangLang.Tokenizer.BUSSIN
        @test tokens[2].type == SlangLang.Tokenizer.SUS
        
        # Test multi-word keywords
        source2 = "no cap"
        tokens2 = SlangLang.Tokenizer.tokenize(source2)
        @test tokens2[1].type == SlangLang.Tokenizer.NOCAP
        @test tokens2[1].value == "no cap"
    end
    
    @testset "Basic Expressions" begin
        # Test simple assignment
        source = "weak x = 42\n"
        julia_code = SlangLang.compile(source)
        @test occursin("x = 42", julia_code)
    end
    
    @testset "Control Flow" begin
        # Test if statement
        source = "bussin sus:\n    ghost\nno cap:\n    ghost\n"
        julia_code = SlangLang.compile(source)
        @test occursin("if true", julia_code)
        @test occursin("else", julia_code)
    end
    
    @testset "Functions" begin
        # Test function definition
        source = "drop greet(name):\n    tea \"Hello, \" + name + \"!\"\n"
        julia_code = SlangLang.compile(source)
        @test occursin("function greet", julia_code)
        @test occursin("return", julia_code)
    end
    
    @testset "Loops" begin
        # Test while loop
        source = "slay sus:\n    periodt\n"
        julia_code = SlangLang.compile(source)
        @test occursin("while true", julia_code)
        @test occursin("break", julia_code)
        
        # Test for loop
        source2 = "let's go i based 1:10:\n    ghost\n"
        julia_code2 = SlangLang.compile(source2)
        @test occursin("for i in", julia_code2)
    end
    
    @testset "Operators" begin
        # Test logical operators
        source = "weak result = sus based sus crazy fake"
        julia_code = SlangLang.compile(source)
        @test occursin("&&", julia_code)
        @test occursin("||", julia_code)
    end
    
    @testset "Error Detection" begin
        # Should detect undefined variables
        source = "tea undefined_var"
        try
            SlangLang.compile(source)
            @test false  # Should not reach here
        catch e
            @test isa(e, ErrorException)
        end
    end
    
    @testset "Complete Program" begin
        # Test a more complex program
        source = "drop factorial(n):\n    bussin n <= 1:\n        tea 1\n    no cap:\n        tea n * factorial(n - 1)\n\nweak result = factorial(5)\n"
        julia_code = SlangLang.compile(source)
        @test occursin("function factorial", julia_code)
        @test occursin("if n <= 1", julia_code)
        @test occursin("return 1", julia_code)
    end
    
    @testset "String Literals" begin
        source = "weak msg = \"Hello Gen Z!\""
        julia_code = SlangLang.compile(source)
        @test occursin("\"Hello Gen Z!\"", julia_code)
    end
    
    @testset "Boolean Literals" begin
        source = "weak truth = sus"
        julia_code = SlangLang.compile(source)
        @test occursin("true", julia_code)
        
        source2 = "weak lie = fake"
        julia_code2 = SlangLang.compile(source2)
        @test occursin("false", julia_code2)
    end
    
end

println("All tests passed!")

end  # module