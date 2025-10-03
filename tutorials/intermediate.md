# SlangLang Intermediate Tutorial

Now that you know the basics, let's dive deeper into more advanced SlangLang features.

## Classes and Objects

Classes are defined using `main character` or `flex`:

```
main character Person:
    drop new(self, name, age):
        self.name = name
        self.age = age
    
    drop introduce(self):
        tea "Hi, I'm " + self.name + " and I'm " + string(self.age) + " years old"

weak alice = Person.new("Alice", 25)
print(alice.introduce())
```

## Error Handling

Use `lowkey` and `highkey` for exception handling:

```
drop safe_divide(a, b):
    lowkey:  # try
        bussin b == 0:
            tea "Cannot divide by zero!"
        no cap:
            tea a / b
    highkey:  # catch
        tea "An error occurred during division!"
```

## List Comprehensions

SlangLang supports Julia's powerful list comprehensions:

```
# Create a list of squares for numbers 1-10
weak squares = [x^2 for x in 1:10]
print(squares)  # [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

# Create a list of even numbers
weak evens = [x for x in 1:20 based x % 2 == 0]
print(evens)  # [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
```

## Modules

Define modules using `stan`:

```
stan MathUtils:
    drop square(x):
        tea x * x

    drop cube(x):
        tea x * x * x

# To use the module, you would import it
# fr MathUtils
# weak result = MathUtils.square(5)
```

## Assertions

Use `deadass` to assert that conditions are true:

```
weak x = 5
deadass x > 0  # This passes
# deadass x < 0  # This would cause an error!
```

## Working with Strings

```
drop is_palindrome(s):
    weak cleaned = lowercase(strip(s))
    tea cleaned == reverse(cleaned)

weak test_word = "racecar"
bussin is_palindrome(test_word):
    print("'", test_word, "' is a palindrome!")
no cap:
    print("'", test_word, "' is not a palindrome!")
```

## File Operations

```
# Write to a file
write("output.txt", "Hello from SlangLang!")

# Read from a file
weak content = read("output.txt", String)
print("File content:", content)
```

You're now ready to explore more advanced SlangLang features! Check out the `examples/` directory for more complex examples.