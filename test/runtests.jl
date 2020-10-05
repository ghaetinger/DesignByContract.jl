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
    @test_throws AssertionError foo(-1, 10, true)
    @test_throws AssertionError foo(5, 2, true)
    @test_throws AssertionError foo(5, 10, false)

    @test_throws AssertionError foo(100, 10, true)
    @test_throws AssertionError foo(5, -100, true)
    @test_throws AssertionError foo(5, -100, false)
end

#TODO: TypeError test!

@require (b > 0)
@ensure (result >= 1)
@contract function flawedReturnDiv(a :: Int64, b :: Int64)
    return a / b
end

setReturnName(:result)

@require (b > 0)
@ensure (result >= 1)
@contract function fixedDiv(a :: Int64, b :: Int64)
    return a / b
end

@testset "Return name change" begin
    @test_throws AssertionError flawedReturnDiv(1, 0)
    @test_throws UndefVarError flawedReturnDiv(1, 2)
    @test_throws UndefVarError flawedReturnDiv(10, 2)

    @test_throws AssertionError fixedDiv(1, 0)
    @test_throws AssertionError fixedDiv(1, 2)
    @test fixedDiv(10, 2) == 5
end
