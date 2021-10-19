struct T行動{T}
    コマンド::T
    行動者::Tキャラクター
    対象者::Tキャラクター
end

function ダメージ計算(攻撃力, 防御力)
    if 攻撃力 < 0
        throw(DomainError("攻撃力が負の値になっています"))
    end
    if 防御力 ≤ 0
        throw(DomainError("防御力が0または負の値になっています"))
    end
    return round(Int, 10 * 攻撃力/防御力)
end

function 攻撃実行!(攻撃者, 防御者, コマンド::T通常攻撃)
    println("----------")
    println("$(攻撃者.名前)の攻撃！")
    防御者ダメージ = ダメージ計算(攻撃者.攻撃力, 防御者.防御力)
    HP減少!(防御者, 防御者ダメージ)
    println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
    println("$(防御者.名前)の残りHP：$(防御者.HP)")
end

function 攻撃実行!(攻撃者, 防御者, スキル::Tスキル)
    println("----------")
    println("$(攻撃者.名前)の$(スキル.名前)！")
    攻撃回数 = rand(スキル.攻撃回数min:スキル.攻撃回数max)
    for _ in 1:攻撃回数
        if rand() < スキル.命中率
            防御者ダメージ = ダメージ計算(攻撃者.攻撃力 * スキル.威力, 防御者.防御力)
            HP減少!(防御者, 防御者ダメージ)
            println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
            println("$(防御者.名前)の残りHP：$(防御者.HP)")
        else
            println("攻撃は失敗した・・・")
        end
    end
end

function 行動決定(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    println(戦況表示(プレイヤーs, モンスターs))
    println("$(行動者.名前)のターン")
    コマンド = コマンド選択(行動者)
    return T行動(コマンド, 行動者, モンスターs[1])
end

function 行動決定(行動者::Tモンスター, プレイヤーs, モンスターs)
    return T行動(T通常攻撃(), 行動者, rand(行動可能な奴ら(プレイヤーs)))
end

function 行動実行!(行動::T行動{<:Union{T通常攻撃, T攻撃スキル}})
    攻撃実行!(行動.行動者, 行動.対象者, 行動.コマンド)
    MP減少!(行動.行動者, 行動.コマンド)
end

function 行動実行!(行動::T行動{Tかばう}) 
    #かばう実行!(行動.行動者, 行動.対象者) #未実装
end

function  is全滅(キャラクターs)
    return all(p.HP == 0 for p in キャラクターs)
end

function is戦闘終了(プレイヤーs, モンスターs)
    return is全滅(プレイヤーs) || is全滅(モンスターs)
end

function 行動順決定(プレイヤーs, モンスターs)
    行動順 = Tキャラクター[]
    append!(行動順, プレイヤーs)
    append!(行動順, モンスターs)
    return shuffle(行動順)
end

function ゲームループ(プレイヤーs, モンスターs)
    while true
        for 行動者 in 行動順決定(プレイヤーs, モンスターs)
            if is行動可能(行動者)
                行動 = 行動決定(行動者, プレイヤーs, モンスターs)
                行動実行!(行動)
                if is戦闘終了(プレイヤーs, モンスターs)
                    return
                end
            end
        end
    end
end