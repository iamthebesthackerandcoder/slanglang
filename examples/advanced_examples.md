# Advanced SlangLang Examples

This directory contains advanced examples demonstrating more complex SlangLang programs.

## Calculator Example

A simple calculator program:

```
drop calculate(operation, a, b):
    bussin operation == "+":
        tea a + b
    bussd operation == "-":
        tea a - b
    bussd operation == "*":
        tea a * b
    bussd operation == "/":
        bussin b != 0:
            tea a / b
        no cap:
            print("Error: Division by zero!")
            tea 0
    no cap:
        print("Error: Unknown operation")
        tea 0

# Example usage
weak result = calculate("+", 5, 3)
print("5 + 3 =", result)
```

## Fibonacci Example

Calculate Fibonacci numbers recursively:

```
drop fibonacci(n):
    bussin n <= 1:
        tea n
    no cap:
        tea fibonacci(n-1) + fibonacci(n-2)

# Print first 10 Fibonacci numbers
let's go i based 0:9:
    print("Fibonacci(", i, ") = ", fibonacci(i))
```

## Object-Oriented Example

A simple class example:

```
main character BankAccount:
    drop new(self, initial_balance):
        self.balance = initial_balance
    
    drop deposit(self, amount):
        self.balance = self.balance + amount
    
    drop withdraw(self, amount):
        bussin amount <= self.balance:
            self.balance = self.balance - amount
            tea sus  # Success
        no cap:
            tea fake  # Failed
    
    drop get_balance(self):
        tea self.balance

# Create and use an account
weak account = BankAccount.new(100)
account.deposit(50)
print("Balance:", account.get_balance())
```

## File Processing Example

A program that processes a text file:

```
drop process_file(filename):
    lowkey:  # try
        weak content = read(filename, String)
        weak lines = split(content, "\n")
        weak line_count = length(lines)
        weak word_count = 0
        
        let's go line based lines:
            weak words = split(strip(line), " ")
            word_count = word_count + length(words)
        
        print("Lines: ", line_count)
        print("Words: ", word_count)
    highkey:  # catch
        print("Error reading file: ", filename)

# Use the function
process_file("sample.txt")
```

These examples show more advanced uses of SlangLang features.