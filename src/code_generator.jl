# code_generator.jl - Code Generator for SlangLang

module CodeGenerator
    using ..AST

    """
    Code generator that translates slang AST to Julia code
    """
    mutable struct CodeGenContext
        output::IOBuffer
        indent_level::Int
        variable_counter::Int
        
        CodeGenContext() = new(IOBuffer(), 0, 0)
    end

    """
    Generate Julia code from the AST program
    """
    function generate_code(ast::AST.Program, context::CodeGenContext=CodeGenContext())
        for stmt in ast.statements
            generate_statement(stmt, context)
        end
        return String(take!(context.output))
    end

    """
    Write with proper indentation
    """
    function write_indented(context::CodeGenContext, str::String)
        write(context.output, repeat("    ", context.indent_level))
        write(context.output, str)
    end

    """
    Increase indentation level
    """
    function indent!(context::CodeGenContext)
        context.indent_level += 1
    end

    """
    Decrease indentation level
    """
    function unindent!(context::CodeGenContext)
        context.indent_level -= 1
    end

    """
    Generate code for a statement
    """
    function generate_statement(stmt::AST.Statement, context::CodeGenContext)
        if isa(stmt, AST.FunctionDef)
            generate_function_definition(stmt, context)
        elseif isa(stmt, AST.ClassDef)
            generate_class_definition(stmt, context)
        elseif isa(stmt, AST.ModuleDef)
            generate_module_definition(stmt, context)
        elseif isa(stmt, AST.IfStmt)
            generate_if_statement(stmt, context)
        elseif isa(stmt, AST.WhileStmt)
            generate_while_statement(stmt, context)
        elseif isa(stmt, AST.ForStmt)
            generate_for_statement(stmt, context)
        elseif isa(stmt, AST.TryStmt)
            generate_try_statement(stmt, context)
        elseif isa(stmt, AST.AssignmentStmt)
            generate_assignment(stmt, context)
        elseif isa(stmt, AST.ReturnStmt)
            generate_return_statement(stmt, context)
        elseif isa(stmt, AST.BreakStmt)
            generate_break_statement(stmt, context)
        elseif isa(stmt, AST.ContinueStmt)
            generate_continue_statement(stmt, context)
        elseif isa(stmt, AST.ExpressionStmt)
            generate_expression(stmt.expression, context)
            write(context.output, "\n")
        elseif isa(stmt, AST.ImportStmt)
            generate_import_statement(stmt, context)
        elseif isa(stmt, AST.AssertStmt)
            generate_assert_statement(stmt, context)
        elseif isa(stmt, AST.RaiseStmt)
            generate_raise_statement(stmt, context)
        elseif isa(stmt, AST.PassStmt)
            # Pass statement is just a comment in Julia
            write_indented(context, "# pass\n")
        else
            write_indented(context, "# Unknown statement: $(typeof(stmt))\n")
        end
    end

    """
    Generate code for a function definition
    """
    function generate_function_definition(func_def::AST.FunctionDef, context::CodeGenContext)
        write_indented(context, "function $(func_def.name)(")
        for (i, param) in enumerate(func_def.parameters)
            write(context.output, param)
            if i < length(func_def.parameters)
                write(context.output, ", ")
            end
        end
        write(context.output, ")\n")
        
        indent!()
        for stmt in func_def.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a class definition (converts to Julia mutable struct)
    """
    function generate_class_definition(class_def::AST.ClassDef, context::CodeGenContext)
        write_indented(context, "mutable struct $(class_def.name)\n")
        
        indent!()
        # For now, we'll just add a placeholder - in a real implementation,
        # we'd need to analyze the class body to determine fields
        write_indented(context, "# Fields would be determined from class body\n")
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a module definition
    """
    function generate_module_definition(module_def::AST.ModuleDef, context::CodeGenContext)
        write_indented(context, "module $(module_def.name)\n")
        
        indent!()
        for stmt in module_def.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for an if statement
    """
    function generate_if_statement(if_stmt::AST.IfStmt, context::CodeGenContext)
        write_indented(context, "if ")
        generate_expression(if_stmt.condition, context)
        write(context.output, "\n")
        
        indent!()
        for stmt in if_stmt.if_body
            generate_statement(stmt, context)
        end
        unindent!()
        
        # Generate elif clauses
        for (condition, body) in if_stmt.elif_clauses
            write_indented(context, "elseif ")
            generate_expression(condition, context)
            write(context.output, "\n")
            
            indent!()
            for stmt in body
                generate_statement(stmt, context)
            end
            unindent!()
        end
        
        # Generate else clause if it exists
        if if_stmt.else_body !== nothing
            write_indented(context, "else\n")
            
            indent!()
            for stmt in if_stmt.else_body
                generate_statement(stmt, context)
            end
            unindent!()
        end
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a while statement
    """
    function generate_while_statement(while_stmt::AST.WhileStmt, context::CodeGenContext)
        write_indented(context, "while ")
        generate_expression(while_stmt.condition, context)
        write(context.output, "\n")
        
        indent!()
        for stmt in while_stmt.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a for statement
    """
    function generate_for_statement(for_stmt::AST.ForStmt, context::CodeGenContext)
        write_indented(context, "for $(for_stmt.variable) in ")
        generate_expression(for_stmt.iterable, context)
        write(context.output, "\n")
        
        indent!()
        for stmt in for_stmt.body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for a try statement
    """
    function generate_try_statement(try_stmt::AST.TryStmt, context::CodeGenContext)
        write_indented(context, "try\n")
        
        indent!()
        for stmt in try_stmt.try_body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "catch\n")
        
        indent!()
        for stmt in try_stmt.except_body
            generate_statement(stmt, context)
        end
        unindent!()
        
        write_indented(context, "end\n\n")
    end

    """
    Generate code for an assignment statement
    """
    function generate_assignment(assignment::AST.AssignmentStmt, context::CodeGenContext)
        generate_expression(assignment.target, context)
        write(context.output, " = ")
        generate_expression(assignment.value, context)
        write(context.output, "\n")
    end

    """
    Generate code for a return statement
    """
    function generate_return_statement(return_stmt::AST.ReturnStmt, context::CodeGenContext)
        write_indented(context, "return")
        if return_stmt.value !== nothing
            write(context.output, " ")
            generate_expression(return_stmt.value, context)
        end
        write(context.output, "\n")
    end

    """
    Generate code for a break statement
    """
    function generate_break_statement(break_stmt::AST.BreakStmt, context::CodeGenContext)
        write_indented(context, "break\n")
    end

    """
    Generate code for a continue statement
    """
    function generate_continue_statement(continue_stmt::AST.ContinueStmt, context::CodeGenContext)
        write_indented(context, "continue\n")
    end

    """
    Generate code for an import statement
    """
    function generate_import_statement(import_stmt::AST.ImportStmt, context::CodeGenContext)
        write_indented(context, "import $(import_stmt.module_name)\n")
    end

    """
    Generate code for an assert statement
    """
    function generate_assert_statement(assert_stmt::AST.AssertStmt, context::CodeGenContext)
        write_indented(context, "Base.@assert ")
        generate_expression(assert_stmt.condition, context)
        write(context.output, "\n")
    end

    """
    Generate code for a raise statement
    """
    function generate_raise_statement(raise_stmt::AST.RaiseStmt, context::CodeGenContext)
        write_indented(context, "throw(")
        generate_expression(raise_stmt.expression, context)
        write(context.output, ")\n")
    end

    """
    Generate code for an expression
    """
    function generate_expression(expr::AST.Expression, context::CodeGenContext)
        if isa(expr, AST.Literal)
            if isa(expr.value, String)
                write(context.output, "\"$(expr.value)\"")
            elseif isa(expr.value, Bool)
                write(context.output, expr.value ? "true" : "false")
            else
                write(context.output, string(expr.value))
            end
        elseif isa(expr, AST.Identifier)
            write(context.output, expr.name)
        elseif isa(expr, AST.BinaryOp)
            generate_binary_op(expr, context)
        elseif isa(expr, AST.UnaryOp)
            generate_unary_op(expr, context)
        elseif isa(expr, AST.Call)
            generate_call(expr, context)
        else
            write(context.output, "# Unknown expression: $(typeof(expr))")
        end
    end

    """
    Generate code for a binary operation
    """
    function generate_binary_op(bin_op::AST.BinaryOp, context::CodeGenContext)
        write(context.output, "(")
        generate_expression(bin_op.left, context)
        
        # Map slang operators to Julia operators
        julia_op = map_slang_op_to_julia(bin_op.op)
        write(context.output, " $julia_op ")
        
        generate_expression(bin_op.right, context)
        write(context.output, ")")
    end

    """
    Map slang operators to Julia operators
    """
    function map_slang_op_to_julia(slang_op::String)
        op_mapping = Dict(
            "based" => "&&",    # and
            "crazy" => "||",    # or
            "cap" => "!=",      # not (this is wrong - 'cap' is negation, not inequality)
            "==" => "==",
            "!=" => "!=",
            "<" => "<",
            ">" => ">",
            "<=" => "<=",
            ">=" => ">=",
            "+" => "+",
            "-" => "-",
            "*" => "*",
            "/" => "/",
            "%" => "%",
            "**" => "^"         # exponentiation
        )
        
        # Special handling for 'cap' which means 'not' in slang but is used for inequality in some contexts
        if slang_op == "cap"
            # This is handled in unary ops, so we shouldn't reach here for 'cap'
            # unless there's an error in the parser
            return "!"  # logical NOT
        end
        
        return get(op_mapping, slang_op, slang_op)
    end

    """
    Generate code for a unary operation
    """
    function generate_unary_op(un_op::AST.UnaryOp, context::CodeGenContext)
        julia_op = un_op.op == "cap" ? "!" : un_op.op  # 'cap' means 'not'
        write(context.output, "($julia_op ")
        generate_expression(un_op.operand, context)
        write(context.output, ")")
    end

    """
    Generate code for a function call
    """
    function generate_call(call::AST.Call, context::CodeGenContext)
        write(context.output, call.func)
        write(context.output, "(")
        for (i, arg) in enumerate(call.args)
            generate_expression(arg, context)
            if i < length(call.args)
                write(context.output, ", ")
            end
        end
        write(context.output, ")")
    end

end  # CodeGenerator module