using DesignByContract
using Test

# Function Contracts
include("./basicAssertionsTests.jl")
include("./returnValueTests.jl")
include("./inputExpressionTests.jl")

# Loop Invariants
include("./loopAssertionTests.jl")
include("./loopInputExpressionsTests.jl")
include("./loopInnerVarianceTests.jl")

# Agreement Disabling
include("./agreementDisablingTests.jl")

# Changeset
include("./changesetTests.jl")
