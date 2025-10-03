# Move AST to a separate core module
module AST

# Base abstract types for AST nodes
abstract type ASTNode end

# Statement types
abstract type Statement <: ASTNode end
abstract type Expression <: ASTNode end

# Program node
mutable struct Program <: ASTNode
    statements::Vector{Statement}
end

# Statement types
mutable struct FunctionDef <: Statement
    name::String
    parameters::Vector{String}
    body::Vector{Statement}
end

mutable struct ClassDef <: Statement
    name::String
    body::Vector{Statement}
end

mutable struct ModuleDef <: Statement
    name::String
    body::Vector{Statement}
end

mutable struct IfStmt <: Statement
    condition::Expression
    if_body::Vector{Statement}
    elif_clauses::Vector{Tuple{Expression, Vector{Statement}}} # (condition, body)
    else_body::Union{Vector{Statement}, Nothing}
end

mutable struct WhileStmt <: Statement
    condition::Expression
    body::Vector{Statement}
end

mutable struct ForStmt <: Statement
    variable::String
    iterable::Expression
    body::Vector{Statement}
end

mutable struct TryStmt <: Statement
    try_body::Vector{Statement}
    except_body::Vector{Statement}
end

mutable struct AssignmentStmt <: Statement
    target::Expression
    value::Expression
end

mutable struct ReturnStmt <: Statement
    value::Union{Expression, Nothing}
end

mutable struct BreakStmt <: Statement
end

mutable struct ContinueStmt <: Statement
end

mutable struct ExpressionStmt <: Statement
    expression::Expression
end

mutable struct ImportStmt <: Statement
    module_name::String
end

mutable struct AssertStmt <: Statement
    condition::Expression
end

mutable struct RaiseStmt <: Statement
    expression::Expression
end

mutable struct PassStmt <: Statement
end

# Expression types
mutable struct Literal <: Expression
    value
end

mutable struct Identifier <: Expression
    name::String
end

mutable struct BinaryOp <: Expression
    left::Expression
    op::String
    right::Expression
end

mutable struct UnaryOp <: Expression
    op::String
    operand::Expression
end

mutable struct Call <: Expression
    func::String
    args::Vector{Expression}
end

end  # module