using Test

function ダメージ計算(攻撃力, 防御力)
    return round(Int, 10 * 攻撃力/防御力)
end

function main()
    モンスターHP = 30
    モンスター防御力 = 10
    プレイヤー攻撃力 = 10

    println("モンスターに遭遇した！")
    println("戦闘開始！")
    
    for _ in 1:3
        println("----------")
        println("勇者の攻撃！")
        モンスターダメージ = ダメージ計算(プレイヤー攻撃力, モンスター防御力)
        モンスターHP = モンスターHP - モンスターダメージ
        println("モンスターは" * string(モンスターダメージ) * "のダメージを受けた！")
        println("モンスターの残りHP：" * string(モンスターHP))
    end

    println("戦闘に勝利した！")
end

main()

