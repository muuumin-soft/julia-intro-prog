using Test

function ダメージ計算(攻撃力, 防御力)
    return round(Int, 10 * 攻撃力/防御力)
end

function main(偽乱数列)
    モンスターHP = 30
    モンスター攻撃力 = 10
    モンスター防御力 = 10
    プレイヤーHP = 30
    プレイヤー攻撃力 = 10
    プレイヤー防御力 = 10

    println("モンスターに遭遇した！")
    println("戦闘開始！")
    
    i = 0
    while true
        i = i + 1
        if 偽乱数列[i] < 0.5
        #if rand() < 0.5
            #勇者が先攻
            println("----------")
            println("勇者の攻撃！")
            モンスターダメージ = ダメージ計算(プレイヤー攻撃力, モンスター防御力)
            モンスターHP = モンスターHP - モンスターダメージ
            println("モンスターは" * string(モンスターダメージ) * "のダメージを受けた！")
            println("モンスターの残りHP：" * string(モンスターHP))
            if モンスターHP == 0
                @test i == 3
                break
            end

            #モンスターが後攻
            println("----------")
            println("モンスターの攻撃！")
            プレイヤーダメージ = ダメージ計算(モンスター攻撃力, プレイヤー防御力)
            プレイヤーHP = プレイヤーHP - プレイヤーダメージ
            println("勇者は" * string(プレイヤーダメージ) * "のダメージを受けた！")
            println("勇者の残りHP：" * string(プレイヤーHP))
            if プレイヤーHP == 0
                @test i == 3
                break
            end
        else
            #モンスターが先攻
            println("----------")
            println("モンスターの攻撃！")
            プレイヤーダメージ = ダメージ計算(モンスター攻撃力, プレイヤー防御力)
            プレイヤーHP = プレイヤーHP - プレイヤーダメージ
            println("勇者は" * string(プレイヤーダメージ) * "のダメージを受けた！")
            println("勇者の残りHP：" * string(プレイヤーHP))
            if プレイヤーHP == 0
                @test i == 3
                break
            end

            #勇者が後攻
            println("----------")
            println("勇者の攻撃！")
            モンスターダメージ = ダメージ計算(プレイヤー攻撃力, モンスター防御力)
            モンスターHP = モンスターHP - モンスターダメージ
            println("モンスターは" * string(モンスターダメージ) * "のダメージを受けた！")
            println("モンスターの残りHP：" * string(モンスターHP))
            if モンスターHP == 0
                @test i == 3
                break
            end
        end
    end

    if モンスターHP == 0
        println("戦闘に勝利した！")        
    else
        println("戦闘に敗北した・・・")
    end
end

@testset "main処理リファクタリング" begin
    main([0.1, 0.1, 0.1])
    main([0.1, 0.1, 0.9])
    main([0.1, 0.9, 0.1])
    main([0.1, 0.9, 0.9])
    main([0.9, 0.1, 0.1])
    main([0.9, 0.1, 0.9])
    main([0.9, 0.9, 0.1])
    main([0.9, 0.9, 0.9])
end

