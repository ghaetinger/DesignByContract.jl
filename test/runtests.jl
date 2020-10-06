using DBC
using Test

@require (a > 0) (b > a) c
@ensure (b < a) (a < 0) !c
@contract function foo(a :: Int64, b :: Int64, c :: Bool)
    a *= -1
    b *= -1
    c = !c
    return
end

@require (a > 0) (b > a) c
@ensure (b < a) (a > b) !c
@contract function flawedEnsureFoo(a :: Int64, b :: Int64, c :: Bool)
    a += 2
    b += 2
    return
end

@testset "Assertion Errors" begin
    @test_throws ContractBreachException foo(-1, 10, true)
    @test_throws ContractBreachException foo(5, 2, true)
    @test_throws ContractBreachException foo(5, 10, false)

    @test_throws ContractBreachException foo(100, 10, true)
    @test_throws ContractBreachException foo(5, -100, true)
    @test_throws ContractBreachException foo(5, -100, false)
end

@require (b > 0)
@ensure (toReturn >= 1)
@contract function flawedReturnDiv(a :: Int64, b :: Int64)
    return a / b
end

setReturnName(:toReturn)

@require (b > 0)
@ensure (toReturn >= 1)
@contract function fixedDiv(a :: Int64, b :: Int64)
    return a / b
end

setReturnName(:result)

@testset "Return name change" begin
    @test_throws ContractBreachException flawedReturnDiv(1, 0)
    @test_throws UndefVarError flawedReturnDiv(1, 2)
    @test_throws UndefVarError flawedReturnDiv(10, 2)

    @test_throws ContractBreachException fixedDiv(1, 0)
    @test_throws ContractBreachException fixedDiv(1, 2)
    @test fixedDiv(10, 2) == 5
end

@require (1 + 2)
@ensure (1 < 2)
@contract function wrongRequireType(a, b)
    return a / b
end

@require sum(ls)
@ensure (result > length(ls))
@contract function wrongListSumOverLength(ls)
    return sum(ls)
end

@require all([x >= 1 for x ∈ ls]) any([x >= 2 for x ∈ ls])
@ensure (result > length(ls))
@contract function listSumOverLength(ls)
    return sum(ls)
end

@testset "Crazy Types as Expressions" begin
    @test_throws TypeError wrongRequireType(1, 2)
    @test_throws TypeError wrongListSumOverLength([1, 2, 1]) == 4

    @test listSumOverLength([1, 2, 1]) == 4
end
