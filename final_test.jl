# Comprehensive test of the SlangLang compiler

include("SlangLang.jl")
using .SlangLang

println("=== SlangLang Compiler - Comprehensive Test ===")

# Test 1: Basic variable assignment
println("\n1. Testing basic variable assignment...")
source1 = "weak x = 42\n"
result1 = SlangLang.compile(source1)
println("Input: weak x = 42")
println("Output: $(repr(result1))")
success1 = occursin("x = 42", result1)
println("Test 1 $(success1 ? "PASSED" : "FAILED"): Basic assignment works")

# Test 2: Function definition
println("\n2. Testing function definition...")
source2 = """
drop add(a, b):
    tea a + b
"""
result2 = SlangLang.compile(source2)
println("Input: Function definition")
println("Output: $(repr(result2))")
success2 = occursin("function add", result2) && occursin("return", result2)
println("Test 2 $(success2 ? "PASSED" : "FAILED"): Function definition works")

# Test 3: Control flow (if statement)
println("\n3. Testing control flow (if statement)...")
source3 = """
weak x = 5
bussin x > 0:
    ghost  # pass
no cap:
    ghost  # pass
"""
result3 = SlangLang.compile(source3)
println("Input: If statement")
println("Output: $(repr(result3))")
success3 = occursin("if x > 0", result3) && occursin("else", result3)
println("Test 3 $(success3 ? "PASSED" : "FAILED"): If statement works")

# Test 4: Loop (while statement)
println("\n4. Testing while loop...")
source4 = """
weak i = 0
slay i < 3:
    i = i + 1
"""
result4 = SlangLang.compile(source4)
println("Input: While loop")
println("Output: $(repr(result4))")
success4 = occursin("while i < 3", result4)
println("Test 4 $(success4 ? "PASSED" : "FAILED"): While loop works")

# Test 5: For loop
println("\n5. Testing for loop...")
source5 = """
let's go num based 1:5:
    ghost  # pass
"""
result5 = SlangLang.compile(source5)
println("Input: For loop")
println("Output: $(repr(result5))")
success5 = occursin("for num in", result5)
println("Test 5 $(success5 ? "PASSED" : "FAILED"): For loop works")

# Test 6: Boolean values
println("\n6. Testing boolean values...")
source6 = "weak truth = sus\nweak lie = fake\n"
result6 = SlangLang.compile(source6)
println("Input: Boolean values")
println("Output: $(repr(result6))")
success6 = occursin("truth = true", result6) && occursin("lie = false", result6)
println("Test 6 $(success6 ? "PASSED" : "FAILED"): Boolean values work")

# Test 7: Operators
println("\n7. Testing operators...")
source7 = "weak result = sus based sus crazy fake\n"
result7 = SlangLang.compile(source7)
println("Input: Logical operators")
println("Output: $(repr(result7))")
success7 = occursin("&&", result7)  # based should map to &&
success7 = success7 && occursin("||", result7)  # crazy should map to ||
println("Test 7 $(success7 ? "PASSED" : "FAILED"): Logical operators work")

# Test 8: Multi-word keywords test
println("\n8. Testing multi-word keywords...")
source8 = "no cap:\n    ghost\n"
result8 = SlangLang.compile(source8)
println("Input: Multi-word keyword (no cap)")
println("Output: $(repr(result8))")
success8 = occursin("else", result8)
println("Test 8 $(success8 ? "PASSED" : "FAILED"): Multi-word keywords work")

all_tests_passed = success1 && success2 && success3 && success4 && success5 && success6 && success7 && success8
println("\n=== Overall Result: $(all_tests_passed ? "ALL TESTS PASSED" : "SOME TESTS FAILED") ===")
println("The SlangLang compiler is working $(all_tests_passed ? "correctly" : "with issues").")

# Additional manual verification
println("\n=== Manual Verification ===")
println("Generated code example:")
example_code = """
drop factorial(n):
    bussin n <= 1:
        tea 1
    no cap:
        tea n * factorial(n - 1)

weak result = factorial(5)
print(result)
"""

println("Slang code:")
println(example_code)

compiled_example = SlangLang.compile(example_code)
println("\nCompiled Julia code:")
println(compiled_example)

println("\n=== Testing Complete ===")