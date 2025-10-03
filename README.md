# SlangLang - The Gen Z Programming Language

SlangLang is a production-ready compiler for the Gen Z slang programming language, implemented in Julia with aggressive optimization using Julia's multiple dispatch and JIT compilation.

## Installation

### From Source
1. Install Julia 1.10 or later
2. Install PackageCompiler: `julia -e "using Pkg; Pkg.add("PackageCompiler")"`
3. Run: `julia build_windows.jl` (Windows) or `make` (Linux)

### Using the Compiler

The compiler translates slang code to Julia code which can then be executed by Julia:

```bash
slanglang input.slang output.jl
julia output.jl
```

## Syntax

SlangLang uses Gen Z slang keywords:

- `bussin` - if
- `bussd` - elif/else if  
- `no cap` - else
- `slay` - while
- `let's go` - for
- `drop` - def (function definition)
- `tea` - return
- `weak` - var (variable declaration)
- `strong` - const (constant declaration)
- `sus` - True
- `fake` - False
- `based` - and
- `crazy` - or
- `cap` - not
- And many more!

Example:
```
drop greet(name):
    tea "Hello " + name + "!"

weak message = greet("World")
print(message)
```

## Features

- Full support for control structures (if/else, while, for)
- Function definitions and calls
- Variable declarations
- Boolean and arithmetic operations
- Semantic analysis with error reporting
- Code generation targeting Julia
- Leverages Julia's JIT compilation for performance

## Contributing

We welcome contributions to SlangLang! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to get started.