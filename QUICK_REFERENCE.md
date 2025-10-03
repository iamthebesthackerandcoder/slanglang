# SlangLang Quick Reference

## Keywords
- `bussin` → if
- `bussd` → elif/else if
- `no cap` → else
- `slay` → while
- `let's go` → for (use with `based` instead of `in`)
- `drop` → def (function definition)
- `tea` → return
- `weak` → var (mutable variable)
- `strong` → const (immutable variable)
- `sus` → True
- `fake` → False
- `based` → and
- `crazy` → or
- `cap` → not
- `periodt` → break
- `sksksk` → continue
- `main character` → class
- `flex` → class/struct
- `yeet` → raise/throw
- `lowkey` → try
- `highkey` → except/catch
- `deadass` → assert
- `send` → yield
- `fr` → import
- `bestie` → from
- `ghost` → pass
- `stan` → module
- `shook` → using/import

## Example Program
```
# Hello World in SlangLang
weak greeting = "Hello, World!"
print(greeting)

# Function definition
drop greet(name):
    tea "Hello " + name + "!"

# Variables
weak user = "SlangLang Developer"
weak message = greet(user)
print(message)

# Conditionals
weak score = 95
bussin score >= 90:
    print("That's bussin!")
bussd score >= 70:
    print("Not bad!")
no cap:
    print("No cap on that performance")

# Loops
weak count = 0
slay count < 3:
    print("Slaying iteration", count)
    count = count + 1

let's go item based ["s", "l", "a", "n", "g"]:
    print(item)

# Error handling
lowkey:
    weak result = 10 / 2
    print("Result:", result)
highkey:
    print("An error occurred!")
```