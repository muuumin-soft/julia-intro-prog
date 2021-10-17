module Game

using Random

mutable struct Tプレイヤー
    名前
    HP
    攻撃力
    防御力
end

mutable struct Tモンスター
    名前
    HP
    攻撃力
    防御力
end

struct T行動
    コマンド
    行動者
    対象者
end

function ダメージ計算(攻撃力, 防御力)
    return round(Int, 10 * 攻撃力/防御力)
end

function HP減少!(防御者, ダメージ)
    if 防御者.HP - ダメージ　< 0
        防御者.HP = 0
    else
        防御者.HP = 防御者.HP - ダメージ
    end
end

function 攻撃実行!(攻撃者, 防御者, コマンド)
    println("----------")
    if コマンド == "1"
        println("$(攻撃者.名前)の攻撃！")
        防御者ダメージ = ダメージ計算(攻撃者.攻撃力, 防御者.防御力)
        HP減少!(防御者, 防御者ダメージ)
        println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
        println("$(防御者.名前)の残りHP：$(防御者.HP)")
    elseif コマンド == "2"
        println("$(攻撃者.名前)の大振り！")
        if rand() < 0.4
            防御者ダメージ = ダメージ計算(攻撃者.攻撃力 * 2, 防御者.防御力)
            HP減少!(防御者, 防御者ダメージ)
            println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
            println("$(防御者.名前)の残りHP：$(防御者.HP)")
        else
            println("攻撃は失敗した・・・")
        end
    end
end

function is行動可能(キャラクター)
    return キャラクター.HP != 0
end

function 行動可能な奴ら(キャラクターs)
    return [c for c in キャラクターs if is行動可能(c)]
end

function 行動順決定(プレイヤーs, モンスターs)
    行動順 = []
    append!(行動順, プレイヤーs)
    append!(行動順, モンスターs)
    return shuffle(行動順)
end

function コマンド選択()
    function isValidコマンド(コマンド)
        return コマンド in ["1", "2"]
    end

    while true
        コマンド = Base.prompt("[1]攻撃[2]大振り")
        if isValidコマンド(コマンド)
            return コマンド            
        else
            println("正しいコマンドを入力してください")
        end
    end 
end

function 戦況表示(プレイヤーs, モンスターs)
    結果 = []
    push!(結果, "*****プレイヤー*****")
    for p in プレイヤーs
        push!(結果, "$(p.名前) HP:$(p.HP)")
    end
    push!(結果, "*****モンスター*****")
    for m in モンスターs
        push!(結果, "$(m.名前) HP:$(m.HP)")
    end
    push!(結果, "********************")
    return join(結果, "\n")
end

function 行動決定(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    println(戦況表示(プレイヤーs, モンスターs))
    println("$(行動者.名前)のターン")
    コマンド = コマンド選択()
    return T行動(コマンド, 行動者, モンスターs[1])
end

function 行動決定(行動者::Tモンスター, プレイヤーs, モンスターs)
    return T行動("1", 行動者, rand(行動可能な奴ら(プレイヤーs)))
end

function 行動実行!(行動)
    攻撃実行!(行動.行動者, 行動.対象者, 行動.コマンド)
end

function  is全滅(キャラクターs)
    return all([p.HP == 0 for p in キャラクターs])
end

function is戦闘終了(プレイヤーs, モンスターs)
    return is全滅(プレイヤーs) || is全滅(モンスターs)
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

function main()
    モンスター = Tモンスター("ドラゴン", 400, 40, 10)
    プレイヤー1 = Tプレイヤー("太郎", 100, 10, 10)
    プレイヤー2 = Tプレイヤー("花子", 100, 10, 10)
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 10, 10)
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 10, 10)

    println("モンスターに遭遇した！")
    println("戦闘開始！")

    ゲームループ([プレイヤー1, プレイヤー2, プレイヤー3, プレイヤー4], [モンスター])

    if モンスター.HP == 0
        println("戦闘に勝利した！")
    else
        println("戦闘に敗北した・・・")
    end
end

end