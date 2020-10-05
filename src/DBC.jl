module DBC

export @require, @ensure, @contract, setReturnName

requirementList = []
ensureList = []
invariantList = []

returnAssignmentName = :toReturn

function fillCheckArray(exprList)
    [:(@assert $item) for item in exprList]
end

function filterEntryExpression(expr)
    filter(x -> typeof(x) == Expr, expr)
end

function substituteReturnStatement(exprList, index)
    returnAssignExp = copy(exprList[index])
    returnAssignExp.head = :(=)
    pushfirst!(returnAssignExp.args, returnAssignmentName)
    insert!(exprList, index, returnAssignExp)
    index+=1
    exprList[index].args = [returnAssignmentName]
    removedReturnStatement = splice!(exprList, index, ensureList)
    insert!(exprList, index + length(ensureList), removedReturnStatement)
end


macro require(expr...)
    global requirementList
    requirementList = fillCheckArray(expr)
    return nothing
end

macro ensure(expr...)
    global ensureList
    ensureList = fillCheckArray(expr)
    return nothing
end

macro contract(expr :: Expr)
    @assert expr.head == :function
    func = Array{Any, 1}(requirementList)
    append!(func, filterEntryExpression(expr.args[2].args))
    returnIndices = filter(x -> func[x].head == :return, [(1:length(func))...])
    for index ∈ returnIndices
        substituteReturnStatement(func, index)
    end
    expr.args[2].args = func
    empty!(requirementList)
    empty!(ensureList)
    expr |> esc
end

function setReturnName(newName :: Symbol)
    global returnAssignmentName
    returnAssignmentName = newName
end

end # module
