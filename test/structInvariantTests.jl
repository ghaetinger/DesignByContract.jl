@structInvariant (
    structure.a < 10,
    structure.b > 15.0,
    structure.c == "TestString"
) struct CoolStructure
    a :: Int64
    b :: Float64
    c :: String
end

@testset "Evaluates checks on initialization" begin
    @test initialize(
        CoolStructure;
        a = 1, b = 20.0, c = "TestString"
    ) == CoolStructure(1, 20.0, "TestString")

    @test_throws ContractBreachException initialize(
        CoolStructure;
        a = 25, b = 20.0, c = "TestString"
    ) 

    @test_throws ContractBreachException initialize(
        CoolStructure;
        a = 1, b = 2.0, c = "TestString"
    )

    @test_throws ContractBreachException initialize(
        CoolStructure;
        a = 1, b = 20.0, c = "TestString NOT!"
    )
end

@testset "Evaluates checks on change" begin
    cool = initialize(
        CoolStructure;
        a = 1, b = 20.0, c = "TestString"
    )

    @test change(cool; a = 2) == CoolStructure(2, 20.0, "TestString")
    @test change(cool; b = 30.0) == CoolStructure(1, 30.0, "TestString")
    @test change(cool; c = "TestString") == CoolStructure(1, 20.0, "TestString")

    @test_throws ContractBreachException change(
        cool; a = 20
    ) == CoolStructure(2, 20.0, "TestString")
    @test_throws ContractBreachException change(
        cool; b = 3.0
    ) == CoolStructure(1, 30.0, "TestString")
    @test_throws ContractBreachException change(
        cool; c = "TestString NOT!"
    ) == CoolStructure(1, 20.0, "TestString")

end

setDefaultStructureName(:str)

@structInvariant (structure.a < 10) struct WrongCoolStructure
    a :: Int64
end

@structInvariant (str.a < 10) struct NewCoolStructure
    a :: Int64
end

@testset "Correctly changes structure name" begin
    @test initialize(NewCoolStructure; a=1) == NewCoolStructure(1)
    @test_throws UndefVarError initialize(WrongCoolStructure; a=1)
end
