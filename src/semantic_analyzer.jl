# semantic_analyzer.jl - Semantic Analyzer for SlangLang

module SemanticAnalyzer
    using ..AST

    # Symbol table for tracking variables, functions, etc.
    mutable struct SymbolTable
        symbols::Dict{String, Any}
        parent::Union{SymbolTable, Nothing}
        
        SymbolTable(parent::Union{SymbolTable, Nothing}=nothing) = new(Dict{String, Any}(), parent)
    end

    # Add a symbol to the table
    function add_symbol!(table::SymbolTable, name::String, value)
        table.symbols[name] = value
    end

    # Look up a symbol in the current or parent scopes
    function lookup_symbol(table::SymbolTable, name::String)
        current_table = table
        while current_table !== nothing
            if haskey(current_table.symbols, name)
                return current_table.symbols[name]
            end
            current_table = current_table.parent
        end
        return nothing
    end

    # Semantic analysis context
    mutable struct SemanticContext
        symbol_table::SymbolTable
        errors::Vector{String}
        current_function::Union{String, Nothing}
        function_defs::Dict{String, AST.FunctionDef}
        
        SemanticContext() = new(SymbolTable(), String[], nothing, Dict{String, AST.FunctionDef}())
    end

    """
    Perform semantic analysis on the AST
    """
    function analyze(ast::AST.Program, context::SemanticContext=SemanticContext())
        for stmt in ast.statements
            analyze_statement(stmt, context)
        end
        return context.errors
    end

    """
    Analyze a statement
    """
    function analyze_statement(stmt::AST.Statement, context::SemanticContext)
        if isa(stmt, AST.FunctionDef)
            analyze_function_definition(stmt, context)
        elseif isa(stmt, AST.ClassDef)
            analyze_class_definition(stmt, context)
        elseif isa(stmt, AST.IfStmt)
            analyze_if_statement(stmt, context)
        elseif isa(stmt, AST.WhileStmt)
            analyze_while_statement(stmt, context)
        elseif isa(stmt, AST.ForStmt)
            analyze_for_statement(stmt, context)
        elseif isa(stmt, AST.TryStmt)
            analyze_try_statement(stmt, context)
        elseif isa(stmt, AST.AssignmentStmt)
            analyze_assignment(stmt, context)
        elseif isa(stmt, AST.ReturnStmt)
            analyze_return_statement(stmt, context)
        elseif isa(stmt, AST.ExpressionStmt)
            analyze_expression(stmt.expression, context)
        elseif isa(stmt, AST.ImportStmt)
            analyze_import_statement(stmt, context)
        elseif isa(stmt, AST.AssertStmt)
            analyze_assert_statement(stmt, context)
        elseif isa(stmt, AST.RaiseStmt)
            analyze_raise_statement(stmt, context)
        elseif isa(stmt, AST.BreakStmt) || isa(stmt, AST.ContinueStmt) || isa(stmt, AST.PassStmt)
            # These statements don't require semantic analysis
        else
            push!(context.errors, "Unknown statement type: $(typeof(stmt))")
        end
    end

    """
    Analyze a function definition
    """
    function analyze_function_definition(func_def::AST.FunctionDef, context::SemanticContext)
        # Add function to function definitions
        context.function_defs[func_def.name] = func_def
        
        # Add function to symbol table
        add_symbol!(context.symbol_table, func_def.name, :function)
        
        # Create new scope for function body
        func_scope = SymbolTable(context.symbol_table)
        
        # Add parameters to function scope
        for param in func_def.parameters
            add_symbol!(func_scope, param, :parameter)
        end
        
        # Save current function and set to new function
        old_function = context.current_function
        context.current_function = func_def.name
        
        # Analyze function body in the new scope
        old_symbol_table = context.symbol_table
        context.symbol_table = func_scope
        
        for stmt in func_def.body
            analyze_statement(stmt, context)
        end
        
        # Restore previous scope and function
        context.symbol_table = old_symbol_table
        context.current_function = old_function
    end

    """
    Analyze a class definition
    """
    function analyze_class_definition(class_def::AST.ClassDef, context::SemanticContext)
        # Add class to symbol table
        add_symbol!(context.symbol_table, class_def.name, :class)
        
        # Create new scope for class body
        class_scope = SymbolTable(context.symbol_table)
        
        # Analyze class body in the new scope
        old_symbol_table = context.symbol_table
        context.symbol_table = class_scope
        
        for stmt in class_def.body
            analyze_statement(stmt, context)
        end
        
        # Restore previous scope
        context.symbol_table = old_symbol_table
    end

    """
    Analyze an if statement
    """
    function analyze_if_statement(if_stmt::AST.IfStmt, context::SemanticContext)
        # Analyze condition
        analyze_expression(if_stmt.condition, context)
        
        # Analyze if body
        old_symbol_table = context.symbol_table
        if_scope = SymbolTable(context.symbol_table)
        context.symbol_table = if_scope
        
        for stmt in if_stmt.if_body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
        
        # Analyze elif clauses
        for (condition, body) in if_stmt.elif_clauses
            analyze_expression(condition, context)
            
            elif_scope = SymbolTable(context.symbol_table)
            context.symbol_table = elif_scope
            for stmt in body
                analyze_statement(stmt, context)
            end
            context.symbol_table = old_symbol_table
        end
        
        # Analyze else body if it exists
        if if_stmt.else_body !== nothing
            else_scope = SymbolTable(context.symbol_table)
            context.symbol_table = else_scope
            for stmt in if_stmt.else_body
                analyze_statement(stmt, context)
            end
            context.symbol_table = old_symbol_table
        end
    end

    """
    Analyze a while statement
    """
    function analyze_while_statement(while_stmt::AST.WhileStmt, context::SemanticContext)
        # Analyze condition
        analyze_expression(while_stmt.condition, context)
        
        # Analyze body
        old_symbol_table = context.symbol_table
        while_scope = SymbolTable(context.symbol_table)
        context.symbol_table = while_scope
        
        for stmt in while_stmt.body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
    end

    """
    Analyze a for statement
    """
    function analyze_for_statement(for_stmt::AST.ForStmt, context::SemanticContext)
        # Analyze iterable
        analyze_expression(for_stmt.iterable, context)
        
        # Add loop variable to scope
        add_symbol!(context.symbol_table, for_stmt.variable, :loop_variable)
        
        # Analyze body
        old_symbol_table = context.symbol_table
        for_scope = SymbolTable(context.symbol_table)
        add_symbol!(for_scope, for_stmt.variable, :loop_variable)
        context.symbol_table = for_scope
        
        for stmt in for_stmt.body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
    end

    """
    Analyze a try statement
    """
    function analyze_try_statement(try_stmt::AST.TryStmt, context::SemanticContext)
        # Analyze try body
        old_symbol_table = context.symbol_table
        try_scope = SymbolTable(context.symbol_table)
        context.symbol_table = try_scope
        
        for stmt in try_stmt.try_body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
        
        # Analyze except body
        except_scope = SymbolTable(context.symbol_table)
        context.symbol_table = except_scope
        
        for stmt in try_stmt.except_body
            analyze_statement(stmt, context)
        end
        context.symbol_table = old_symbol_table
    end

    """
    Analyze an assignment statement
    """
    function analyze_assignment(assignment::AST.AssignmentStmt, context::SemanticContext)
        # Analyze the value being assigned
        analyze_expression(assignment.value, context)
        
        # For now, just add the variable to symbol table
        # In a more complete implementation, we'd check if the target is valid
        if isa(assignment.target, AST.Identifier)
            add_symbol!(context.symbol_table, assignment.target.name, :variable)
        end
    end

    """
    Analyze a return statement
    """
    function analyze_return_statement(return_stmt::AST.ReturnStmt, context::SemanticContext)
        if return_stmt.value !== nothing
            analyze_expression(return_stmt.value, context)
        end
        
        # Check if return is inside a function
        if context.current_function === nothing
            push!(context.errors, "Return statement outside function at $(return_stmt)")
        end
    end

    """
    Analyze an import statement
    """
    function analyze_import_statement(import_stmt::AST.ImportStmt, context::SemanticContext)
        # For now, just record the import
        add_symbol!(context.symbol_table, import_stmt.module_name, :imported_module)
    end

    """
    Analyze an assert statement
    """
    function analyze_assert_statement(assert_stmt::AST.AssertStmt, context::SemanticContext)
        # Analyze the assertion condition
        analyze_expression(assert_stmt.condition, context)
    end

    """
    Analyze a raise statement
    """
    function analyze_raise_statement(raise_stmt::AST.RaiseStmt, context::SemanticContext)
        # Analyze the expression being raised
        analyze_expression(raise_stmt.expression, context)
    end

    """
    Analyze an expression
    """
    function analyze_expression(expr::AST.Expression, context::SemanticContext)
        if isa(expr, AST.Literal)
            # Literals don't need semantic analysis
        elseif isa(expr, AST.Identifier)
            # Check if identifier is defined in current or parent scopes
            if lookup_symbol(context.symbol_table, expr.name) === nothing
                push!(context.errors, "Undefined variable: $(expr.name)")
            end
        elseif isa(expr, AST.BinaryOp)
            analyze_expression(expr.left, context)
            analyze_expression(expr.right, context)
        elseif isa(expr, AST.UnaryOp)
            analyze_expression(expr.operand, context)
        elseif isa(expr, AST.Call)
            analyze_call(expr, context)
        else
            push!(context.errors, "Unknown expression type: $(typeof(expr))")
        end
    end

    """
    Analyze a function call
    """
    function analyze_call(call::AST.Call, context::SemanticContext)
        # Check if function is defined
        if lookup_symbol(context.symbol_table, call.func) === nothing
            if !haskey(context.function_defs, call.func)
                push!(context.errors, "Undefined function: $(call.func)")
            end
        end
        
        # Analyze arguments
        for arg in call.args
            analyze_expression(arg, context)
        end
    end

end  # SemanticAnalyzer module