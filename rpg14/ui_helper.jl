include("全角半角判定.jl")

function 名前表示調整(名前)
    function 文字幅(文字)
        if is半角(文字)
            return 1
        elseif is全角(文字)
            return 2
        else 
            throw(ArgumentError("不正な文字です"))
        end
    end
    function 必要な半角スペース(名前)
        最終文字列幅 = 16
        名前文字列幅 = sum(文字幅(x) for x in 名前)
        n = 最終文字列幅 - 名前文字列幅
        return " "^n
    end

    return 名前 * 必要な半角スペース(名前)
end