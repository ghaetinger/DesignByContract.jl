module DBC
include("./agreements.jl")

export @contract, ContractBreachException

returnAssignmentName = :result

# Check Expressions list generation

function createCheckExpressions(functionName :: String, agreement :: Agreement)
    return [contractHolds(functionName, agreement, i) for i in 1:length(agreement.expressions)]
end

# Return setup functions

function getReturnPoints(exprList)
    return filter(x -> (typeof(exprList[x]) == Expr &&
                        exprList[x].head == :return), [(1:length(exprList))...])
end

function findCustomReturnName(expression)
    returnNameExpr = getAgreementsFromExpressions(:resultName, :(=), expression)
    if length(returnNameExpr) == 0
        return returnAssignmentName
    elseif length(returnNameExpr) != 1
        throw(AttributeError("Custom Return names should be added in the format 'resultName = \$customName'"))
    else
        return returnNameExpr[1]
    end
end

function produceReturnVariableAssign(returnExpr :: Expr)
    returnAssignExpr = copy(returnExpr)
    returnAssignExpr.head = :(=)
    return returnAssignExpr
end

function produceNewReturnExpr(returnName :: Symbol)
    return :(return $returnName)
end

function setupReturn!(exprList, newExpressions,
                      index :: Int64, returnName :: Symbol)
    returnAssignExpr = produceReturnVariableAssign(exprList[index])
    pushfirst!(returnAssignExpr.args, returnName)
    insert!(exprList, index, returnAssignExpr)
    splice!(exprList, index+1, newExpressions)
    insert!(exprList, index+1+length(newExpressions), produceNewReturnExpr(returnName))
end

function setupReturnSet!(exprList, returnIndices :: Array{Int64},
                        newExpressions, returnName :: Symbol)
    for returnIndex ∈ returnIndices
        setupReturn!(exprList, newExpressions, returnIndex, returnName)
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
    start = createCheckExpressions(agreement.functionName, agreement)
    pushfirst!(functionBody.args, start...)
end

function addEnsures!(functionBody :: Expr, agreement :: Agreement, returnName :: Symbol)
    finish = createCheckExpressions(agreement.functionName, agreement)
    returnIndices = getReturnPoints(functionBody.args)
    setupReturnSet!(functionBody.args, returnIndices, finish, returnName)
end

generateEnsureFunction(returnName :: Symbol) = (x, y) -> addEnsures!(x, y, returnName)

function addFuncInvariants!(functionBody :: Expr, agreement :: Agreement)
    return nothing
end

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
        funcInvariant => Agreement(funcInvariant, addFuncInvariants!, functionName),
    )

    for agreement in values(agreements)
        lookAndFillType(agreement, expr)
        agreement(functionBody)
    end

    return functionExpr |> esc
end

end # module
