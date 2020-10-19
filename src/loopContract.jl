loopSym = [:while, :for]

function addLoopInvariant!(loopBody::Expr, agreement::Agreement)
    check = createCheckExpressions(agreement)
    newExpr = Expr(:block)
    newExpr.args = [check..., loopBody.args[2:end]...]
    loopBody.args = [loopBody.args[1], newExpr]
end

macro loopinvariant(expr...)
    loopAgreement = Agreement(loopInvariant, addLoopInvariant!, nothing)
    loopBody = nothing
    for item in expr
        if typeof(item) == Expr
            item.head in loopSym ? (loopBody = item;break) : push!(loopAgreement.expressions, item)
        else
            newExpr = Expr(:block)
            newExpr.args = [item]
            push!(loopAgreement.expressions, newExpr)
        end
    end
    loopAgreement(loopBody)
    return loopBody |> esc
end
