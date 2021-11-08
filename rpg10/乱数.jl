using Random

function get乱数生成器()
    return function exec()
        return rand()
    end
end

function get乱数生成器stub()
    function 数列生成(c::Channel)
        val = 0
        while (true)
            put!(c, float(val))
            val += 1//10
            if val == 1
                val = 0
            end
        end
    end
    chnl = Channel(数列生成);

    return function exec()
        return take!(chnl)
    end
end