struct Changeset{T}
    value :: T
    types :: Dict
    changes :: Base.Iterators.Pairs 
    errors :: Vector{Tuple{Symbol, String}}
    isValid :: Bool
end

struct InvalidChangesetException{T} <: Exception
    changeset :: Changeset{T}
end

function Base.show(io :: IO, exception :: InvalidChangesetException)
    println(io, "Invalid Changeset")
    show(io, exception.changeset.errors)
end

function Base.show(io::IO, m::Changeset{T}) where T
    println(io, "Changeset{$(T)} {")
    println(io, "   data: $(m.value)")
    println(io, "   types: $(m.types)")
    println(io, "   changes: $(m.changes)")
    println(io, "   errors: $(m.errors)")
    println(io, "   isValid: $(m.isValid)")
    println(io, "}")
end

function __init__()
    Base.Experimental.register_error_hint(MethodError) do io, exc, argtypes, kwargs
        if typeof(exc) == MethodError 
            printstyled(io, "\n\nDid you start the structure with @with_kw?\n", color=:cyan)
        end
    end
end

function applyChangeset(changeset :: Changeset{T}) :: T where T
    if changeset.isValid
        T(changeset.value, changeset.changes)
    else
       changeset |> InvalidChangesetException |> throw
    end
end

function buildNameTypeDictionary(structure :: DataType) :: Dict{Symbol, DataType}
    names = structure |> fieldnames |> collect
    types = structure |> fieldtypes |> collect
    return hcat(names, types) |> eachrow .|> Tuple |> Dict 
end

function castFields(object :: T; args...) :: Changeset{T} where T
    nameTypeDict = buildNameTypeDictionary(T)
    isValid = true
    errors = []
    for key in keys(args)
        if !(haskey(nameTypeDict, key)) || typeof(args[key]) != nameTypeDict[key]
            isValid = false
            errors = vcat(errors, [(key, "Invalid cast")])
        end
    end
    return Changeset{T}(
        object,
        nameTypeDict,
        args,
        errors,
        isValid
    )
end

function changeset(object :: T; args...) :: Changeset{T} where T
    castFields(object; args...)
end
