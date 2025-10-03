# SlangLang Language Specification

## Version 0.1.0

## Table of Contents
1. [Introduction](#introduction)
2. [Lexical Structure](#lexical-structure)
3. [Data Types](#data-types)
4. [Expressions](#expressions)
5. [Statements](#statements)
6. [Functions](#functions)
7. [Control Flow](#control-flow)
8. [Modules and Classes](#modules-and-classes)
9. [Error Handling](#error-handling)
10. [Standard Library](#standard-library)

## Introduction

SlangLang is a programming language designed to use Gen Z slang terms as keywords, making programming more relatable and fun. It compiles to Julia code to leverage Julia's high-performance JIT compilation and multiple dispatch.

## Lexical Structure

### Comments
Comments begin with `#` and continue to the end of the line:
```
# This is a comment
weak x = 10  # This is also a comment
```

### Identifiers
Identifiers start with a letter or underscore, followed by letters, digits, or underscores:
```
my_variable
_user_name
variable123
```

### Keywords
SlangLang uses Gen Z slang terms as keywords:

| Slang Keyword | Traditional Equivalent | Description |
|---------------|------------------------|-------------|
| `bussin` | `if` | Conditional statement |
| `bussd` | `elif/else if` | Else-if conditional statement |
| `no cap` | `else` | Else conditional statement |
| `slay` | `while` | While loop |
| `let's go` | `for` | For loop (use with `based`) |
| `drop` | `def` | Function definition |
| `tea` | `return` | Return statement |
| `weak` | `var` | Mutable variable declaration |
| `strong` | `const` | Immutable variable declaration |
| `sus` | `True` | Boolean true value |
| `fake` | `False` | Boolean false value |
| `based` | `and` | Logical AND operator |
| `crazy` | `or` | Logical OR operator |
| `cap` | `not` | Logical NOT operator |
| `periodt` | `break` | Break statement |
| `sksksk` | `continue` | Continue statement |
| `main character` | `class` | Class definition |
| `flex` | `class/struct` | Class/structure definition |
| `yeet` | `raise/throw` | Throw exception |
| `lowkey` | `try` | Try block |
| `highkey` | `except/catch` | Except/catch block |
| `deadass` | `assert` | Assertion statement |
| `send` | `yield` | Yield statement |
| `fr` | `import` | Import statement |
| `bestie` | `from` | From import statement |
| `ghost` | `pass` | Pass statement |
| `stan` | `module` | Module definition |
| `shook` | `using/import` | Using/import statement |

### Literals

#### Integer Literals
Integer literals are sequences of digits:
```
42
-17
0
```

#### Float Literals
Float literals contain a decimal point:
```
3.14
-2.5
0.0
```

#### String Literals
String literals are enclosed in double quotes or single quotes:
```
"Hello, World!"
'Hello, World!'
```

#### Boolean Literals
Boolean literals are `sus` (true) and `fake` (false):
```
sus
fake
```

## Data Types

SlangLang supports the same data types as Julia:

- Integers (`Int`)
- Floats (`Float64`)
- Strings (`String`)
- Booleans (`Bool`)
- Arrays (`Array`)
- Dictionaries (`Dict`)
- Functions (`Function`)

## Expressions

### Arithmetic Operators
- `+` - Addition
- `-` - Subtraction
- `*` - Multiplication
- `/` - Division
- `%` - Modulo
- `**` - Exponentiation

### Comparison Operators
- `==` - Equal to
- `!=` - Not equal to
- `<` - Less than
- `>` - Greater than
- `<=` - Less than or equal
- `>=` - Greater than or equal

### Logical Operators
- `based` - Logical AND
- `crazy` - Logical OR
- `cap` - Logical NOT

### Function Calls
```
function_name(argument1, argument2)
```

## Statements

### Variable Assignment
```
weak variable_name = value
strong variable_name = value
```

### Expression Statement
An expression followed by a newline:
```
function_call()
variable
```

### Import Statement
```
fr module_name
```

## Functions

Functions are defined using the `drop` keyword:
```
drop function_name(parameter1, parameter2):
    # function body
    tea return_value
```

## Control Flow

### If Statements
```
bussin condition:
    # if body
bussd condition:  # optional
    # elif body
no cap:  # optional
    # else body
```

### While Loops
```
slay condition:
    # loop body
```

### For Loops
```
let's go variable based iterable:
    # loop body
```

### Break and Continue
- `periodt` - Exits the current loop
- `sksksk` - Skips to the next iteration of the current loop

## Modules and Classes

### Modules
Modules are defined using the `stan` keyword:
```
stan ModuleName:
    # module body
```

### Classes
Classes are defined using the `main character` or `flex` keyword:
```
main character ClassName:
    # class body
```

## Error Handling

Error handling uses `lowkey` (try) and `highkey` (except):
```
lowkey:
    # risky code
highkey:
    # exception handling code
```

## Standard Library

SlangLang compiles to Julia, so all of Julia's functions and packages are available. Commonly used functions include:

- `print(value)` - Print to console
- `println(value)` - Print with newline
- `length(collection)` - Length of collection
- `push!(collection, item)` - Add item to collection
- `abs(x)` - Absolute value
- `sqrt(x)` - Square root
- `round(x)` - Round to nearest integer