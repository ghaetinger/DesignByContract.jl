module DBC
export @require, @ensure, @contract, setReturnName, ContractBreachException

include("./agreements.jl")

requirements = Agreement(require, [], agreementBreachMessage[:require])
ensures = Agreement(ensure, [], agreementBreachMessage[:ensure])
funcInvariants = Agreement(funcInvariant, [], agreementBreachMessage[:funcInvariant])

returnAssignmentName = :result


function edgeCheckExpressions(functionName :: String, agreement :: Agreement)
    return [contractHolds(functionName, agreement, i) for i in 1:length(agreement.expressions)]
end

function filterLineNumbers(exprList)
    return filter(x -> typeof(x) != LineNumberNode, exprList)
end

function setupEdges(functionName :: String)
    start = edgeCheckExpressions(functionName, requirements)
    finish = edgeCheckExpressions(functionName, ensures)
    return start, finish
end

function getReturnPoints(exprList)
    return filter(x -> exprList[x].head == :return, [(1:length(exprList))...])
end

function produceReturnVariableAssign(returnExpr :: Expr)
    returnAssignExpr = copy(returnExpr)
    returnAssignExpr.head = :(=)
    return returnAssignExpr
end

function produceNewReturnExpr()
    return :(return $returnAssignmentName)
end

function setupReturn!(exprList, newExpressions,
                      index :: Int64)
    returnAssignExpr = produceReturnVariableAssign(exprList[index])
    pushfirst!(returnAssignExpr.args, returnAssignmentName)
    insert!(exprList, index, returnAssignExpr)
    splice!(exprList, index+1, newExpressions)
    insert!(exprList, index+1+length(newExpressions), produceNewReturnExpr())
end

function setupReturnSet!(returnIndices :: Array{Int64}, exprList,
                        newExpressions)
    for returnIndex ∈ returnIndices
        setupReturn!(exprList, newExpressions, returnIndex)
    end
end

function checkExpressionEntry(exprList)
    if any(x -> (typeof(x) != Symbol && typeof(x) != Expr), exprList)
        throw(ArgumentError(string("Acceptable types are Symbol and Expr, found: \n",
              string([typeof(x) for x in exprList]))))
    end
end

macro require(exprList...)
    global requirements
    checkExpressionEntry(exprList)
    requirements.expressions = [exprList...]
    return nothing
end

macro ensure(exprList...)
    global ensures
    checkExpressionEntry(exprList)
    ensures.expressions = [exprList...]
    return nothing
end

macro contract(expr :: Expr)
    @assert expr.head == :function
    body, finish = setupEdges(string(expr.args[1].args[1]))
    append!(body, filterLineNumbers(expr.args[2].args))
    returnIndices = getReturnPoints(body)
    setupReturnSet!(returnIndices, body, finish)
    expr.args[2].args = body
    empty!(requirements)
    empty!(ensures)
    expr |> esc
end

function setReturnName(newName :: Symbol)
    global returnAssignmentName
    returnAssignmentName = newName
end

end # module
