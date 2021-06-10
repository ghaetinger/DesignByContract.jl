module DesignByContract
using MacroTools, Parameters
include("./agreements.jl")
include("./functionContract.jl")
include("./loopContract.jl")
include("./structureInvariant.jl")

export @contract, @loopinvariant, @structInvariant, initialize, change, setDefaultStructureName, setAgreementEnabling, ContractBreachException

end # module
