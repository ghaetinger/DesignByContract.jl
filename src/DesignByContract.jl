module DesignByContract
using MacroTools
include("./agreements.jl")
include("./functionContract.jl")
include("./loopContract.jl")

export @contract, @loopinvariant, setAgreementEnabling, ContractBreachException

end # module
