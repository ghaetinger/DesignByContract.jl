@contract begin
    require(b > 0)
    ensure(toReturn >= 1)
    function flawedReturnDiv(a::Int64, b::Int64)
        return a / b
    end
end

@contract begin
    require(b > 0)
    ensure(toReturn >= 1)
    returnName = toReturn
    function fixedDiv(a::Int64, b::Int64)
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

wrongReturnNameInt = quote
    @contract begin
        returnName = 2
        function stub()
            return 2
        end
    end
end

wrongReturnNameBool = quote
    @contract begin
        returnName = true
        function stub()
            return 2
        end
    end
end

wrongReturnNameExpr = quote
    @contract begin
        returnName = x -> x + 2
        function stub()
            return 2
        end
    end
end

@testset "new ReturnName Type" begin
    try
        eval(wrongReturnNameInt)
    catch e
        @test typeof(e.error) == ArgumentError
    end
    try
        eval(wrongReturnNameBool)
    catch e
        @test typeof(e.error) == ArgumentError
    end
    try
        eval(wrongReturnNameExpr)
    catch e
        @test typeof(e.error) == ArgumentError
    end
end

@contract begin
    ensure(result >= 0)
    function wrongNestedValue(; x = 0, y = 0)
        if x == 0
            return 0
        elseif x == 1
            if y == 0
                return 0
            elseif y == 1
                return -1
            end
        end
        return -2
    end
end

@testset "Nested returns" begin
    @test_throws ContractBreachException wrongNestedValue(x = 1, y = 1)
    @test_throws ContractBreachException wrongNestedValue(x = 2)
    @test wrongNestedValue() == 0
    @test wrongNestedValue(x = 1) == 0
end
