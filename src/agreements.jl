@enum AgreementType begin
    require
    ensure
    loopInvariant
end

AgreementsEnabled = true

agreementBreachMessage = Dict(
    require => "Breach on Requirement Expression",
    ensure => "Breach on Ensure Expression",
    loopInvariant => "Breach on Loop Invariant Expression",
)

mutable struct Agreement
    type::AgreementType
    expressions::Array{Union{Expr,Symbol}}
    breachMessage::String
    processFunction::Any
    functionName::Union{String,Nothing}
end

function Agreement(
    agreementType::AgreementType,
    addChecksFunction,
    functionName::Union{String,Nothing},
)::Agreement
    Agreement(
        agreementType,
        [],
        agreementBreachMessage[agreementType],
        addChecksFunction,
        functionName,
    )
end

function (agreement::Agreement)(functionBody::Expr)
    AgreementsEnabled ? agreement.processFunction(functionBody, agreement) : functionBody
end

struct ContractBreachException <: Exception
    functionName::Union{String,Nothing}
    expression::String
    breachMessage::String
end

function Base.showerror(io::IO, e::ContractBreachException)
    print(io, "ContractBreachException: ", e.breachMessage, " '", e.expression, "'")
    if !isnothing(e.functionName)
        print(io, " in function '", e.functionName, "'")
    end
end

function agreementHolds(agreement::Agreement, expressionIndex::Int64)
    contractExpression = agreement.expressions[expressionIndex]
    stringContractExpression = string(contractExpression)
    exceptionThrownExpression = :(throw(
        ContractBreachException(
            $(agreement.functionName),
            $stringContractExpression,
            $(agreement.breachMessage),
        ),
    ))

    checkExpression = Expr(:block)
    checkExpression.head = :if
    checkExpression.args =
        [agreement.expressions[expressionIndex], :nothing, exceptionThrownExpression]
    return checkExpression
end

# Check Expressions list generation

function createCheckExpressions(agreement::Agreement)
    return [agreementHolds(agreement, i) for i = 1:length(agreement.expressions)]
end

function setAgreementEnabling(bool::Bool)
    global AgreementsEnabled
    AgreementsEnabled = bool
end
