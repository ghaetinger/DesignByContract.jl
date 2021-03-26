@testset "Crazy Types as Loop Invariants" begin
    a = 0
    @test_throws TypeError begin
        @loopinvariant 2 for i = 1:10
            a += 1
        end
    end

    @test_throws TypeError begin
        @loopinvariant :sym for i = 1:10
            a += 1
        end
    end

    @test_throws TypeError begin
        @loopinvariant (x -> 10 + x) for i = 1:10
            a += 1
        end
    end

    @test begin
        @loopinvariant true for i = 1:10
            a += 1
        end
        a == 10
    end

    a = 0
    @test begin
        @loopinvariant all((x -> 10 + x < 100).([a, 10, 20, 30, a])) for i = 1:10
            a += 1
        end
        a == 10
    end
end
