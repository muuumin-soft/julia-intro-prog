using Random

function get乱数生成器()
    return function exec()
        return rand()
    end
end

function get乱数生成器stub()
    return get乱数生成器stub([0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9])
end

function get乱数生成器stub(指定数列)
    if length(指定数列) == 0
        throw(DomainError("指定数列として1つ以上の要素を含むようにしてください"))
    end
    function 数列生成(c::Channel)
        i = 1
        while (true)
            put!(c, 指定数列[i])
            i += 1
            if length(指定数列) < i
                i = 1
            end
        end
    end
    chnl = Channel(数列生成);
    
    return function exec()
        return take!(chnl)
    end
end