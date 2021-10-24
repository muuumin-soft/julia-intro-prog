include("行動系統.jl")

function コマンド選択(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    function get対象リスト(スキル::T行動内容)
        get対象リスト(行動系統(スキル))
    end

    function get対象リスト(::T攻撃系行動)
        return モンスターs
    end

    function get対象リスト(::Tかばう行動)
        return プレイヤーs
    end

    function RadioMenu作成(選択肢)
        while true
            r = RadioMenu(選択肢, pagesize=4)
            選択index = request("選択してください:", r)
    
            if 選択index == -1
                println("正しいコマンドを入力してください")
                continue
            else
                return 選択index
            end
        end
    end

    function 行動対象を選択し行動を決定(行動内容::T行動内容)
        対象リスト = get対象リスト(行動内容)
        if length(対象リスト) == 1
            return T行動(行動内容, 行動者, 対象リスト[1])
        else
            選択index = RadioMenu作成([s.名前 for s in 対象リスト])
            対象者 = 対象リスト[選択index]
            return T行動(行動内容, 行動者, 対象者)
        end
    end

    while true
        選択index = RadioMenu作成(["攻撃", "スキル"])
        if 選択index == 1
            return 行動対象を選択し行動を決定(T通常攻撃())
        elseif 選択index == 2
            選択index = RadioMenu作成([s.名前 * string(s.消費MP) for s in 行動者.スキルs])
            if 行動者.MP < 行動者.スキルs[選択index].消費MP 
                println("MPが足りません")
                continue
            end
            選択スキル = 行動者.スキルs[選択index]
            return 行動対象を選択し行動を決定(選択スキル)
        else
            throw(DomainError("行動選択でありえない選択肢が選ばれています"))
        end
    end 
end

function 戦況表示(プレイヤーs, モンスターs)
    結果 = []
    push!(結果, "*****プレイヤー*****")
    for p in プレイヤーs
        push!(結果, "$(p.名前) HP:$(p.HP) MP:$(p.MP)")
    end
    push!(結果, "*****モンスター*****")
    for m in モンスターs
        push!(結果, "$(m.名前) HP:$(m.HP) MP:$(m.MP)")
    end
    push!(結果, "********************")
    return join(結果, "\n")
end
