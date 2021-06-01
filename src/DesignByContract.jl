module DesignByContract
using MacroTools
include("./agreements.jl")
include("./functionContract.jl")
include("./loopContract.jl")
include("./changesetAgreement.jl")

export @contract, @loopinvariant, # Contracts
       setAgreementEnabling, # Configuration
       ContractBreachException, # Errors
       Changeset, applyChangeset, changeset, # Changeset
       InvalidChangesetException # Changeset Error

end # module
