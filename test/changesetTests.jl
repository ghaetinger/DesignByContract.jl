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

newA = 2
newB = 3.0
newC = "new sample string"

sampleKeywordlessStructure = KeywordlessStruct(1, 2.0, "sample string")
sampleKeywordStructure = KeywordStruct(1, 2.0, "sample string")

structureChangeset = changeset(sampleKeywordStructure; a = newA, b = newB, c = newC)
structureKeylessChangeset =
    changeset(sampleKeywordlessStructure; a = newA, b = newB, c = newC)

invalidA = ""
invalidB = rand(Int64)
invalidC = rand(Float64)

invalidChangeset =
    changeset(sampleKeywordStructure; a = invalidA, b = invalidB, c = invalidC)

@testset "Creates Changeset for KeywordStruct" begin

    @test structureChangeset.isValid
    @test structureChangeset.changes == Dict(:a => newA, :b => newB, :c => newC)
    @test structureChangeset.errors == []

    @test !invalidChangeset.isValid
    @test invalidChangeset.changes == Dict(:a => invalidA, :b => invalidB, :c => invalidC)
    @test invalidChangeset.errors == [:a, :b, :c] .|> var -> (var, "Invalid cast")
end

@testset "Applies Changeset for KeywordStruct" begin
    @test applyChangeset(structureChangeset) == KeywordStruct(newA, newB, newC)

    @test_throws InvalidChangesetException{KeywordStruct} applyChangeset(invalidChangeset)

    try
        applyChangeset(invalidChangeset)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test contains(String(take!(b)), "Invalid Changeset")
    end
end

@testset "Shows Changeset correctly formatted" begin
    b = IOBuffer()
    show(b, structureChangeset)
    outString = String(take!(b))

    @test contains(
        outString,
        "   types: [\n      a => Int64\n      b => Float64\n      c => String\n   ]",
    )
    @test contains(
        outString,
        "   changes: [\n      a => $(newA)\n      b => $(newB)\n      c => $(newC)\n   ]",
    )
    @test contains(outString, "errors: []")
    @test contains(outString, "isValid: true")
    @test contains(outString, "Changeset{KeywordStruct}")

    b = IOBuffer()
    show(b, invalidChangeset)
    outString = String(take!(b))

    @test contains(
        outString,
        "   types: [\n      a => Int64\n      b => Float64\n      c => String\n   ]",
    )
    @test contains(
        outString,
        "   changes: [\n      a => $(invalidA)\n      b => $(invalidB)\n      c => $(invalidC)\n   ]",
    )
    @test contains(
        outString,
        "errors: [\n      a => Invalid cast\n      b => Invalid cast\n      c => Invalid cast\n   ]",
    )
    @test contains(outString, "isValid: false")
    @test contains(outString, "Changeset{KeywordStruct}")
end

@testset "Shows Invalid Changeset Error correctly formatted" begin
    try
        applyChangeset(invalidChangeset)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test contains(String(take!(b)), "Invalid Changeset\n")
    end
end

@testset "Applying a Changeset for KeywordlessStruct throws an error" begin
    @test_throws MethodError applyChangeset(structureKeylessChangeset)

    try
        applyChangeset(structureKeylessChangeset)
    catch e
        b = IOBuffer()
        showerror(b, e)
        @test contains(String(take!(b)), "Did you start the structure with @with_kw?")
    end
end
