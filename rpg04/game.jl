using Test

mutable struct キャラクター
    名前
    HP
    攻撃力
    防御力
end

function ダメージ計算(攻撃力, 防御力)
    return round(Int, 10 * 攻撃力/防御力)
end

function 攻撃実行!(攻撃者, 防御者)
    println("----------")
    println("$(攻撃者.名前)の攻撃！")
    防御者ダメージ = ダメージ計算(攻撃者.攻撃力, 防御者.防御力)
    防御者.HP = 防御者.HP - 防御者ダメージ
    println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
    println("$(防御者.名前)の残りHP：$(防御者.HP)")
end

function 行動順決定(プレイヤー, モンスター, 乱数)
    if 乱数 < 0.5
        return [[プレイヤー, モンスター], [モンスター, プレイヤー]]
    else
        return [[モンスター, プレイヤー], [プレイヤー, モンスター]]
    end
end

function ゲームループ(プレイヤー, モンスター)
    while true
        for 攻防 in 行動順決定(プレイヤー, モンスター, rand())
            攻撃者, 防御者 = 攻防
            攻撃実行!(攻撃者, 防御者)
            if 防御者.HP == 0
                return
            end    
        end
    end
end

function main()
    モンスター = キャラクター("モンスター", 30, 10, 10)
    プレイヤー = キャラクター("勇者", 30, 10, 10)

    println("モンスターに遭遇した！")
    println("戦闘開始！")

    ゲームループ(プレイヤー, モンスター)

    if モンスター.HP == 0
        println("戦闘に勝利した！")
    else
        println("戦闘に敗北した・・・")
    end
end

main()