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
        item.head in loopSym ? (loopBody = item;break) : push!(loopAgreement.expressions, item)
    end
    loopAgreement(loopBody)
    return loopBody |> esc
end
