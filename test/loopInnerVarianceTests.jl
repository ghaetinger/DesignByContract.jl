@testset "Varying value inbetween loop endpoints" begin
    a = 0
    @test_throws ContractBreachException begin
        @loopinvariant (a >= 0) for i = 1:10
            buf = a
            a = -1
            a = buf+1
        end
        a == 10
    end
end
