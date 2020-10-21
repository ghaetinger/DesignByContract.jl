using DBC
using Test

# Function Contracts
include("./basicAssertionsTests.jl")
include("./returnValueTests.jl")
include("./inputExpressionTests.jl")

# Loop Invariants
include("./loopAssertionTests.jl")
include("./loopInputExpressionsTests.jl")
include("./loopInnerVarianceTests.jl")
