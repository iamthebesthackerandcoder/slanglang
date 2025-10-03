# Contributing to SlangLang

Thank you for your interest in contributing to SlangLang! We're excited to have you join our community of developers.

## Getting Started

### Prerequisites
- Julia 1.10 or later
- Git
- Basic knowledge of Julia programming language

### Setting up the development environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```
   git clone https://github.com/your-username/slanglang.git
   ```
3. Navigate to the project directory:
   ```
   cd slanglang
   ```
4. Install dependencies:
   ```
   julia -e "using Pkg; Pkg.instantiate()"
   ```

## How to Contribute

### Reporting Bugs
- Use the GitHub issue tracker to report bugs
- Describe the issue clearly and include steps to reproduce
- Mention your Julia version and operating system

### Suggesting Features
- Open an issue to discuss new features before implementing
- Explain the use case for the feature
- Consider how it fits with the overall vision of SlangLang

### Making Changes
1. Create a new branch for your changes
2. Make your changes
3. Add tests if applicable
4. Update documentation as needed
5. Submit a pull request

## Code Style Guidelines

### Julia Code
- Follow the Julia style guide
- Use descriptive function and variable names
- Add docstrings to public functions
- Keep functions focused and relatively small

### SlangLang Code Examples
- Use appropriate slang keywords
- Write clear, self-documenting examples
- Follow best practices for the language

## Development Workflow

1. Create an issue for the feature/bug you're working on (if not already created)
2. Fork the repository and create a feature branch
3. Write code and tests
4. Run tests to ensure everything works
5. Submit a pull request with a clear description
6. Address any feedback from code review

## Running Tests

To run the test suite:
```
julia -e "using Pkg; Pkg.test()"
```

Or run specific test files:
```
julia simple_test.jl
julia core_test.jl
julia final_test.jl
```

## Questions?

If you have any questions, feel free to open an issue with the "question" label.

Thank you for contributing to SlangLang!