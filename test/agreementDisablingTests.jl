setAgreementEnabling(false)

@contract begin
    require(a > 0, b > a, c)
    ensure(b < a, a < 0, !c)
    function foo(a :: Int64, b :: Int64, c :: Bool)
        a *= -1
        b *= -1
        c = !c
        return a
    end
end


@contract begin
    require(a > 0, b > a, c)
    ensure(b < a, a > b, !c)
    function flawedEnsureFoo(a :: Int64, b :: Int64, c :: Bool)
        a -= 2
        b += 2
        c = true
        return a
    end
end

@testset "Disabled Require/Ensure" begin
    @test foo(-1, 10, true) == 1
    @test foo(5, 2, true) == -5
    @test foo(5, 10, false) == -5

    @test flawedEnsureFoo(10, 100, true) == 8
    @test flawedEnsureFoo(5, 100, true) == 3
    @test flawedEnsureFoo(2, 100, true) == 0
end

@testset "Disable Loop Invariant" begin
    a = 0
    @test begin
        @loopinvariant (a >= 0) for i = 1:10
            a += 1
        end
        a == 10
    end

    @test begin
        @loopinvariant (a >= 5) for i = 1:10
            a -= 1
        end
        a == 0
    end
end
