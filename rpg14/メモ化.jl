function メモ化(func)
    memo = Dict()
    function メモ化されたfunc(args...; kwargs...)
        allargs = (args, kwargs)
        if haskey(memo, allargs)
            return memo[allargs]
        end
        val = func(args...; kwargs...)
        memo[allargs] = val
        return val
    end
end