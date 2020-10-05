using DBC
using Test

@require (a > 0) (b > a) c
@ensure (b < a) (a > b) !c
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
    c = true
    return
end

@testset "Assertion Errors" begin
    @test_throws AssertionError foo(-1, 10, true)
    @test_throws AssertionError foo(5, 2, true)
    @test_throws AssertionError foo(5, 10, false)

    @test_throws AssertionError foo(100, 10, false)
    @test_throws AssertionError foo(5, -100, false)
end
