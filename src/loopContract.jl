loopSym = [:while, :for]

function addLoopInvariant!(loopBody::Expr, agreement::Agreement)
    check = createCheckExpressions(agreement)
    newExpr = Expr(:block)
    newExpr.args = [loopBody.args[2].args; check]

    innerExpr = copy(loopBody)
    innerExpr.args = [loopBody.args[1], newExpr]
    loopBody.head = :block
    loopBody.args = [check..., innerExpr]
end

"""
@loopinvariant

Takes in a loop expression and fills it with invariant checks.

```julia-repl
julia> a = 0
0

julia> @loopinvariant (a >= 0) for i in 1:10
           a -= 10
       end
ERROR: ContractBreachException: Breach on Loop Invariant Expression 'a >= 0'
...

julia> a = 100
100

julia> @loopinvariant (a >= 0) for i in 1:10
           a -= 10
       end

julia> a = 100
100


julia> i = 1
1

julia> @loopinvariant (a >= 0) (i % 2 == 0) while(i <= 11)
           a -= 10
           i += 2
       end
ERROR: ContractBreachException: Breach on Loop Invariant Expression 'i % 2 == 0'
...
```
"""
macro loopinvariant(expr...)
    loopAgreement = Agreement(loopInvariant, addLoopInvariant!, nothing)
    loopBody = nothing
    for item in expr
        if typeof(item) == Expr
            item.head in loopSym ? (loopBody = item; break) :
            push!(loopAgreement.expressions, item)
        else
            newExpr = Expr(:block)
            newExpr.args = [item]
            push!(loopAgreement.expressions, newExpr)
        end
    end
    loopAgreement(loopBody)
    return loopBody |> esc
end
