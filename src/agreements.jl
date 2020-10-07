@enum AgreementType begin
    require
    ensure
    funcInvariant
end

agreementBreachMessage = Dict(
                          require => "Breach on Requirement Expression",
                          ensure => "Breach on Ensure Expression",
                          funcInvariant => "Breach on Function Invariant Expression",
                          )

mutable struct Agreement
    type :: AgreementType
    expressions :: Array{Union{Expr, Symbol}}
    breachMessage :: String
    processFunction
    functionName :: String
end

function Agreement(agreementType :: AgreementType,
                   addChecksFunction,
                   functionName :: String) :: Agreement
    Agreement(agreementType, [],
              agreementBreachMessage[agreementType],
              addChecksFunction,
              functionName)
end

function (agreement::Agreement)(functionBody::Expr)
    agreement.processFunction(functionBody, agreement)
end

function Base.empty!(agreement :: Agreement)
    empty!(agreement.expressions)
end

struct ContractBreachException <: Exception
    functionName :: String
    expression :: String
    breachMessage :: String
end

function Base.showerror(io::IO, e::ContractBreachException)
    print(io, e.breachMessage, " '", e.expression, "' in function '", e.functionName, "'")
end

function contractHolds(functionName :: String, agreement :: Agreement, expressionIndex :: Int64)
    contractExpression = agreement.expressions[expressionIndex]
    stringContractExpression = string(contractExpression)
    exceptionThrownExpression = :(throw(
        ContractBreachException($functionName,
                                $stringContractExpression,
                                $(agreement.breachMessage))
    ))

    checkExpression = Expr(:block)
    checkExpression.head = :if
    checkExpression.args = [agreement.expressions[expressionIndex],
                            :nothing,
                            exceptionThrownExpression]
    return checkExpression
end
