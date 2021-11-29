function メモ化用hash(x::Any)
    return メモ化用hash(x, UInt(0))
end

function メモ化用hash(x, h::UInt)
    return Base.hash(x, h)
end

function メモ化用hash_allargs(args...; kwargs...)
    h = UInt(0)
    for arg in args
        h = メモ化用hash(arg, h)
    end
    for kwarg in kwargs
        h = メモ化用hash(kwarg.first, h)
        h = メモ化用hash(kwarg.second, h)
    end
    return h
end

function メモ化(func)
    memo = Dict()
    function メモ化されたfunc(args...; kwargs...)
        key = メモ化用hash_allargs(args...; kwargs...)
        if haskey(memo, key)
            return memo[key]
        end
        val = func(args...; kwargs...)
        memo[key] = val
        return val
    end
end