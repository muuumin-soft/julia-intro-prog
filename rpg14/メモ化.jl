function メモ化(func)
    memo = Dict()
    function メモ化されたfunc(arg)
        if haskey(memo, arg)
            return memo[arg]
        end
        val = func(arg)
        memo[arg] = val
        return val
    end
end