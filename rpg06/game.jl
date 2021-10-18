module Game

using Random
import REPL
using REPL.TerminalMenus

mutable struct Tプレイヤー
    名前
    HP
    攻撃力
    防御力
    スキルs
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

struct T通常攻撃 end

struct Tスキル
    名前
    威力
    命中率
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
    if rand() < スキル.命中率
        防御者ダメージ = ダメージ計算(攻撃者.攻撃力 * スキル.威力, 防御者.防御力)
        HP減少!(防御者, 防御者ダメージ)
        println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
        println("$(防御者.名前)の残りHP：$(防御者.HP)")
    else
        println("攻撃は失敗した・・・")
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
            選択肢 = RadioMenu([s.名前 for s in 行動者.スキルs], pagesize=4)
            選択index = request("スキルを選択してください:", 選択肢)
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
    コマンド = コマンド選択(行動者)
    return T行動(コマンド, 行動者, モンスターs[1])
end

function 行動決定(行動者::Tモンスター, プレイヤーs, モンスターs)
    return T行動(T通常攻撃(), 行動者, rand(行動可能な奴ら(プレイヤーs)))
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

function createスキル(スキルシンボル)
    if スキルシンボル === :大振り
        return Tスキル("大振り", 2, 0.4)
    else
        Throw(DomainError("未定義のスキルが指定されました"))
    end
end

function main()
    モンスター = Tモンスター("ドラゴン", 400, 40, 10)
    プレイヤー1 = Tプレイヤー("太郎", 100, 10, 10, [createスキル(:大振り), createスキル(:大振り)])
    プレイヤー2 = Tプレイヤー("花子", 100, 10, 10, [createスキル(:大振り), createスキル(:大振り)])
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 10, 10, [createスキル(:大振り), createスキル(:大振り)])
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 10, 10, [createスキル(:大振り), createスキル(:大振り)])

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