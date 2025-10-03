# SlangLang Tutorial - Getting Started

Welcome to SlangLang! This tutorial will help you get started with the basics of the language.

## Basic Syntax

In SlangLang, you'll use Gen Z slang keywords. Here's a hello world example:

```
weak message = "Hello, World!"
print(message)
```

## Variables

SlangLang has two types of variable declarations:

- `weak` for mutable variables (can be changed)
- `strong` for immutable variables (cannot be changed)

```
weak name = "Alice"        # This can change
strong birth_year = 2000   # This cannot change

name = "Bob"               # This works
# birth_year = 1999       # This would cause an error
```

## Functions

Functions are defined using the `drop` keyword:

```
drop greet(name):
    tea "Hello " + name + "!"

weak message = greet("World")
print(message)
```

The `tea` keyword is used to return a value from a function.

## Conditionals

Use `bussin`, `bussd`, and `no cap` for conditionals:

```
weak age = 18

bussin age >= 18:
    print("You're an adult!")
bussd age >= 13:
    print("You're a teenager!")
no cap:
    print("You're a child!")
```

## Loops

For loops use `let's go` and `based` (meaning "in"):

```
weak items = ["apple", "banana", "cherry"]

let's go item based items:
    print(item)
```

While loops use `slay`:

```
weak count = 0

slay count < 5:
    print("Count is", count)
    count = count + 1
```

## Logical Operators

- `based` - AND (equivalent to `&&`)
- `crazy` - OR (equivalent to `||`)
- `cap` - NOT (equivalent to `!`)

```
weak a = sus  # True
weak b = fake  # False

bussin a based cap b:  # True AND (NOT False) = True
    print("Condition is bussin!")
```

## More Examples

Check out the `examples/` directory for more detailed examples of SlangLang programs.