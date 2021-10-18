function コマンド選択(行動者::Tプレイヤー)
    while true
        選択肢 = RadioMenu(["攻撃", "スキル"], pagesize=4)
        選択index = request("行動を選択してください:", 選択肢)

        if 選択index == -1
            println("正しいコマンドを入力してください")
            continue
        end

        if 選択index == 1
            return T通常攻撃()
        elseif 選択index == 2
            選択肢 = RadioMenu([s.名前 * string(s.消費MP) for s in 行動者.スキルs], pagesize=4)
            選択index = request("スキルを選択してください:", 選択肢)
            if 行動者.MP < 行動者.スキルs[選択index].消費MP 
                println("MPが足りません")
                continue
            end
            return 行動者.スキルs[選択index]
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
