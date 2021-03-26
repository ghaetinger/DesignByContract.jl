@testset "Hiring/Breaking Loops" begin
    a = 0
    @test begin
        @loopinvariant (a >= 0) for i = 1:10
            a += 1
        end
        a == 10
    end

    @test_throws ContractBreachException begin
        @loopinvariant (a >= 5) for i = 1:10
            a -= 1
        end
        a == 10
    end

    a = 0
    b = a
    @test begin
        @loopinvariant (a == 0) (b >= a) for i = 1:10
            b += 1
        end
        b == 10
    end

    a = 0
    @test begin
        @loopinvariant (a == 0) (b >= a) for i = 1:10
            b += 1
        end
        b != 10
    end

    a = 0
    b = a
    @test_throws ContractBreachException begin
        @loopinvariant (a == 0) (b >= a) for i = 1:10
            a += 1
        end
        b == 10
    end
end

@testset "Loop Breach Log" begin

    a = 0
    try
        @loopinvariant (a >= 5) for i = 1:10
            a -= 1
        end
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test String(take!(b)) ==
              "ContractBreachException: Breach on Loop Invariant Expression 'a >= 5'"
    end

    try
        a = 0
        b = 100
        @loopinvariant (b >= a) (a == 0) for i = 1:10
            a += 1
        end
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test String(take!(b)) ==
              "ContractBreachException: Breach on Loop Invariant Expression 'a == 0'"
    end
end