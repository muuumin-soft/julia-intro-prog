struct EastAsianWidthMatcher_単一コードポイント
    reg
end

function EastAsianWidthMatcher_単一コードポイント()
    EastAsianWidthMatcher_単一コードポイント(r"^([0-9A-F]{4});(F|H|W|Na|A|N) *#.*$")
end

function Base.occursin(matcher::EastAsianWidthMatcher_単一コードポイント, 定義行)
    return occursin(matcher.reg, 定義行)
end

struct EastAsianWidthMatcher_範囲コードポイント
    reg
end

function EastAsianWidthMatcher_範囲コードポイント()
    EastAsianWidthMatcher_範囲コードポイント(r"^([0-9A-F]{4}..[0-9A-F]{4});(F|H|W|Na|A|N) *#.*$")
end

function Base.occursin(matcher::EastAsianWidthMatcher_範囲コードポイント, 定義行)
    return occursin(matcher.reg, 定義行)
end

for (tp, f) in [(:EastAsianWidthMatcher_単一コードポイント, :(==))
                (:EastAsianWidthMatcher_範囲コードポイント, :in)]
    @eval begin
        function east_asian_width特性抽出(matcher::$tp, コードポイント, 定義行)
            m = match(matcher.reg, 定義行)
            定義行中コードポイント = eval範囲コードポイント(m.captures[1])
            if $f(コードポイント, 定義行中コードポイント)
                east_asian_width = m.captures[2] 
                return (true, east_asian_width)
            else
                return (false, nothing)
            end
        end        
    end
end

function 十六進数prefix付与(範囲コードポイント)
    function prefix付与(s)
        return "0x" * s
    end
    return replace(範囲コードポイント, r"[0-9A-F]{4}" => prefix付与)
end

function eval範囲コードポイント(範囲コードポイント)
    range = 十六進数prefix付与(範囲コードポイント) #"0x0041..0x005A"という文字列に変換
    code_str = replace(range, ".." => ":") #"0x0041:0x005A"という文字列に変換
    expr = Meta.parse(code_str) #:(0x0041:0x005A) という抽象構文木に変換
    return eval(expr) #抽象構文木を評価
end

struct 全角半角判定器
    is全角
    is半角
end

function create全角半角判定器()
    path = joinpath(@__DIR__, "EastAsianWidth.txt")
    lines = open(path, "r") do f
        readlines(f)
    end

    function get_east_asian_width(コードポイント, 定義行)
        matchers = [
            EastAsianWidthMatcher_単一コードポイント()
            EastAsianWidthMatcher_範囲コードポイント()
        ]
    
        for matcher in matchers
            if occursin(matcher, 定義行)
                return east_asian_width特性抽出(matcher, コードポイント, 定義行)
            end
        end
        return (false, nothing)
    end        

    function get_east_asian_width(コードポイント)
        for 定義行 in lines
            can_match, east_asian_width = get_east_asian_width(コードポイント, 定義行)
            if can_match
                return east_asian_width
            end
        end
    end    
            
    function is全角byEastAsianWidth特性(e)
        if !(e in ["Na", "N", "W", "F", "H", "A"])
            throw(DomainError("無効なeast_asian_width特性です"))
        end
        return e in ["W", "F", "A"]
    end    

    function is全角(c)    
        コードポイント = Int(c)
        e = get_east_asian_width(コードポイント)
        return is全角byEastAsianWidth特性(e)
    end

    function is半角(c)
        return !is全角(c)
    end

    return 全角半角判定器(is全角, is半角)
end
