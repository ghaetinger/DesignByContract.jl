using Parameters

@with_kw struct KeywordStruct
    a::Int64
    b::Float64
    c::String
end

struct KeywordlessStruct
    a::Int64
    b::Float64
    c::String
end

sampleKeywordStructure = KeywordStruct(1, 2.0, "sample string")

@testset "Creates Changeset for KeywordStruct" begin
    newA = 2
    newB = 3.0
    newC = "new sample string"
    structureChangeset = changeset(sampleKeywordStructure; a=newA, b=newB, c=newC)

    @test structureChangeset.isValid
    @test structureChangeset.changes == Dict(:a => newA, :b => newB, :c => newC)
    @test structureChangeset.errors == []

    invalidA = ""
    invalidB = 2
    invalidC = 4.0

    invalidChangeset = changeset(sampleKeywordStructure; a=invalidA, b=invalidB, c=invalidC)

    @test !invalidChangeset.isValid
    @test invalidChangeset.changes == Dict(:a => invalidA, :b => invalidB, :c => invalidC)
    @test invalidChangeset.errors == [:a, :b, :c] .|> var -> (var, "Invalid cast")
end

@testset "Applies Changeset for KeywordStruct" begin
    newA = 2
    newB = 3.0
    newC = "new sample string"
    structureChangeset = changeset(sampleKeywordStructure; a=newA, b=newB, c=newC)

    @test applyChangeset(structureChangeset) == KeywordStruct(newA, newB, newC)

    invalidA = ""
    invalidB = 2
    invalidC = 4.0

    invalidChangeset = changeset(sampleKeywordStructure; a=invalidA, b=invalidB, c=invalidC)

    @test_throws InvalidChangesetException{KeywordStruct} applyChangeset(invalidChangeset)

    try
        applyChangeset(invalidChangeset)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test contains(String(take!(b)), "Invalid Changeset")
    end
end


sampleKeywordlessStructure = KeywordlessStruct(1, 2.0, "sample string")


@testset "Applying a Changeset for KeywordlessStruct throws an error" begin
    newA = 2
    newB = 3.0
    newC = "new sample string"
    structureChangeset = changeset(sampleKeywordlessStructure; a=newA, b=newB, c=newC)

    @test_throws MethodError applyChangeset(structureChangeset)

    try
        applyChangeset(structureChangeset)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test contains(String(take!(b)), "Did you start the structure with @with_kw?")
    end
end
