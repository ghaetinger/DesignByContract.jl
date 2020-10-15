returnAssignmentName = :result

# Return setup functions

function findCustomReturnName(expression)
    returnNameExpr = getAgreementsFromExpressions(:returnName, :(=), expression)
    if length(returnNameExpr) == 0
        return returnAssignmentName
    elseif length(returnNameExpr) != 1 || typeof(returnNameExpr[1]) != Symbol
        throw(ArgumentError("Custom Return names should be added in the format 'resultName = \$customName'"))
    else
        return returnNameExpr[1]
    end
end

# Expression list setup by Agreement

function getAgreementsFromExpressions(agreementType :: Symbol, head :: Symbol, expressions)
    conditions = []
    for expr in expressions
        if typeof(expr) == Expr &&
            expr.head == head && expr.args[1] == agreementType
            append!(conditions, expr.args[2:end])
        end
    end
    return conditions
end

function lookAndFillType(agreement :: Agreement,
                         topExpr)
    typeSym = Symbol(agreement.type)
    conditions = getAgreementsFromExpressions(typeSym, :call, topExpr.args)
    append!(agreement.expressions, conditions)
end

# Agreement setups on function Body

function addRequirements!(functionBody :: Expr, agreement :: Agreement)
    start = createCheckExpressions(agreement)
    pushfirst!(functionBody.args, start...)
end

function addEnsures!(functionBody :: Expr, agreement :: Agreement, returnName :: Symbol)
    finish = createCheckExpressions(agreement)
    push!(finish, :(return $returnName))
    newFunctionBody = MacroTools.postwalk(functionBody) do x
        @capture(x, return a_) || return x
        newReturn = Expr(:block)
        newReturn.args = vcat([:($returnName = $a)], finish)
        return newReturn
    end
    functionBody.args = newFunctionBody.args
    functionBody.head = newFunctionBody.head
end

generateEnsureFunction(returnName :: Symbol) = (x, y) -> addEnsures!(x, y, returnName)

# Finding function

function seekFunctionDefinition(expressions)
    for expr ∈ expressions
        if typeof(expr) == Expr && expr.head == :function
            return expr
        end
    end
end

# Contract macro
macro contract(expr)
    @assert expr.head == :block
    functionExpr = seekFunctionDefinition(expr.args)
    @assert typeof(functionExpr) == Expr "Check the arguments previous to the function declaration!"
    functionName = string(functionExpr.args[1].args[1])
    functionBody = functionExpr.args[2]

    returnName = findCustomReturnName(expr.args)

    agreements = Dict(
        require => Agreement(require, addRequirements!, functionName),
        ensure => Agreement(ensure, generateEnsureFunction(returnName), functionName),
    )

    for agreement in values(agreements)
        lookAndFillType(agreement, expr)
        agreement(functionBody)
    end

    return functionExpr |> esc
end
