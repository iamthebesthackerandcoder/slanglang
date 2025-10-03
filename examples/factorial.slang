# Example slang program
# This program calculates factorial using Gen Z slang keywords

drop calculate_factorial(n):
    bussin n <= 1:
        tea 1
    no cap:
        tea n * calculate_factorial(n - 1)

weak number = 5
weak result = calculate_factorial(number)

drop main():
    print("Factorial of ", number, " is ", result)
    deadass result == 120  # Assert the result is correct

tea main()