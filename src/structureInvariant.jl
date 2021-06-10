structureReferenceName = :structure

function setDefaultStructureName(newName :: Symbol)
    global structureReferenceName
    structureReferenceName = newName
end

function addStructureInvariant!(structureBody :: Expr, agreement :: Agreement)
    newExpr = Expr(:block)

    newMacroexpandExpr = Expr(:macrocall)
    newStructExpr = Expr(:macrocall) 
    newStructExpr.args = [Symbol("@with_kw"), LineNumberNode(0, :none), structureBody]
    newMacroexpandExpr.args = [Symbol("@macroexpand"), LineNumberNode(0, :none), newStructExpr]

    checks = createCheckExpressions(agreement)

    functionExpr = :(
        function DesignByContract.change($(structureReferenceName) :: $(Symbol(agreement.name)); changes...)
            $(structureReferenceName) =
                $(Symbol(agreement.name))($(structureReferenceName); changes...)
            $(checks...)
            return $(structureReferenceName)
        end
    )

    newExpr.args = [eval(newMacroexpandExpr), functionExpr]

    esc(newExpr)
end

macro structInvariant(expr...)
    @assert length(expr) == 2 "Incorrect amount of parameters"

    validationExpressions = expr[1].args
    @assert length(validationExpressions) > 0 "No invariants set"
    
    structExpr = expr[2]
    @assert structExpr.head == :struct "Not the correct parameter format"
    structName = structExpr.args[2] |> string
    
    structureAgreement = Agreement(structInvariant, addStructureInvariant!, structName)
    if typeof(validationExpressions[1]) == Expr
        structureAgreement.expressions = collect(validationExpressions)
    else
        structureAgreement.expressions = [Expr(:call, validationExpressions...)]
    end

    structureAgreement(structExpr)
end

function change(structure :: Any;)
    error("`change` not implemented for $(typeof(structure))")
end

function initialize(mod :: Type; changes...)
    structure = mod(;changes...)
    # TODO: Find a way to use a global scoped function
    return change(structure;)
end
