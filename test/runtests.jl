using DBC
using Test

@contract begin
    require(a > 0, b > a, c)
    ensure(b < a, a < 0, !c)
    function foo(a :: Int64, b :: Int64, c :: Bool)
        a *= -1
        b *= -1
        c = !c
        return
    end
end


@contract begin
    require(a > 0, b > a, c)
    ensure(b < a, a > b, !c)
    function flawedEnsureFoo(a :: Int64, b :: Int64, c :: Bool)
        a -= 2
        b += 2
        c = true
        return
    end
end

@testset "Assertion Errors" begin
    @test_throws ContractBreachException foo(-1, 10, true)
    @test_throws ContractBreachException foo(5, 2, true)
    @test_throws ContractBreachException foo(5, 10, false)
   
    @test_throws ContractBreachException flawedEnsureFoo(10, 100, true)
    @test_throws ContractBreachException flawedEnsureFoo(5, 100, true)
    @test_throws ContractBreachException flawedEnsureFoo(2, 100, true)
end

@testset "Contract Breach Description" begin
    try
        foo(-1, 10, true)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test String(take!(b)) == "Breach on Requirement Expression 'a > 0' in function 'foo'"
    end

    try
        flawedEnsureFoo(10, 100, true)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test String(take!(b)) == "Breach on Ensure Expression 'b < a' in function 'flawedEnsureFoo'"
    end
end

@contract begin
    require(b > 0)
    ensure(toReturn >= 1)
    function flawedReturnDiv(a :: Int64, b :: Int64)
        return a / b
    end
end

@contract begin
    require(b > 0)
    ensure(toReturn >= 1)
    resultName = toReturn
    function fixedDiv(a :: Int64, b :: Int64)
        return a / b
    end
end

@testset "Return name change" begin
    @test_throws ContractBreachException flawedReturnDiv(1, 0)
    @test_throws UndefVarError flawedReturnDiv(1, 2)
    @test_throws UndefVarError flawedReturnDiv(10, 2)

    @test_throws ContractBreachException fixedDiv(1, 0)
    @test_throws ContractBreachException fixedDiv(1, 2)
    @test fixedDiv(10, 2) == 5
end

@contract begin
    require(1 + 2)
    ensure(1 < 2)
    function wrongRequireType(a, b)
        return a / b
    end
end

@contract begin
    require(sum(ls))
    ensure(result > length(ls))
    function wrongListSumOverLength(ls)
        return sum(ls)
    end
end

@contract begin
    require(all([x >= 1 for x ∈ ls]), any([x >= 2 for x ∈ ls]))
    ensure(result > length(ls))
    function listSumOverLength(ls)
        return sum(ls)
    end
end

@testset "Crazy Types as Expressions" begin
    @test_throws TypeError wrongRequireType(1, 2)
    @test_throws TypeError wrongListSumOverLength([1, 2, 1]) == 4

    @test listSumOverLength([1, 2, 1]) == 4
end
