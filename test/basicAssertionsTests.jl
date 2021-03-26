@contract begin
    require(a > 0, b > a, c)
    ensure(b < a, a < 0, !c)
    function foo(a::Int64, b::Int64, c::Bool)
        a *= -1
        b *= -1
        c = !c
        return
    end
end


@contract begin
    require(a > 0, b > a, c)
    ensure(b < a, a > b, !c)
    function flawedEnsureFoo(a::Int64, b::Int64, c::Bool)
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
        @test String(take!(b)) ==
              "ContractBreachException: Breach on Requirement Expression 'a > 0' in function 'foo'"
    end

    try
        flawedEnsureFoo(10, 100, true)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test String(take!(b)) ==
              "ContractBreachException: Breach on Ensure Expression 'b < a' in function 'flawedEnsureFoo'"
    end
end
