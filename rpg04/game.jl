module Game

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

function 行動順決定(プレイヤー, モンスター, 乱数)
    if 乱数 < 0.5
        return [[プレイヤー, モンスター], [モンスター, プレイヤー]]
    else
        return [[モンスター, プレイヤー], [プレイヤー, モンスター]]
    end
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

function 行動実行!(攻撃者::Tプレイヤー, 防御者)
    println("勇者のターン")
    コマンド = コマンド選択()
    攻撃実行!(攻撃者, 防御者, コマンド)
end

function 行動実行!(攻撃者::Tモンスター, 防御者)
    攻撃実行!(攻撃者, 防御者, "1")
end

function ゲームループ(プレイヤー, モンスター)
    while true
        for 攻防 in 行動順決定(プレイヤー, モンスター, rand())
            攻撃者, 防御者 = 攻防
            行動実行!(攻撃者, 防御者)
            if 防御者.HP == 0
                return
            end    
        end
    end
end

function main()
    モンスター = Tモンスター("モンスター", 30, 10, 10)
    プレイヤー = Tプレイヤー("勇者", 30, 10, 10)

    println("モンスターに遭遇した！")
    println("戦闘開始！")

    ゲームループ(プレイヤー, モンスター)

    if モンスター.HP == 0
        println("戦闘に勝利した！")
    else
        println("戦闘に敗北した・・・")
    end
end

end