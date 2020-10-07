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
