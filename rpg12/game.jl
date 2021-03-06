using Random
import REPL
using REPL.TerminalMenus

include("スキル.jl")
include("キャラクター.jl")
include("戦闘.jl")

function モンスター遭遇イベント通知!(リスナーs, 描画ツール)
    for リスナー in リスナーs
        リスナー(描画ツール)
    end
end

function 戦闘勝利イベント通知!(リスナーs, 描画ツール)
    for リスナー in リスナーs
        リスナー(描画ツール)
    end
end

function 戦闘敗北イベント通知!(リスナーs, 描画ツール)
    for リスナー in リスナーs
        リスナー(描画ツール)
    end
end

function main(乱数生成器)
    プレイヤー1 = Tプレイヤー("太郎", 100, 20, 10, 10, [createスキル(:連続攻撃), createスキル(:かばう), createスキル(:ヒール), createスキル(:刃に毒を塗る)])
    プレイヤー2 = Tプレイヤー("花子", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:連続攻撃)])
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:かばう)])
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 20, 10, 10, [createスキル(:ヒール), createスキル(:連続攻撃)])

    モンスター1 = Tモンスター("ボスドラゴン", 400, 80, 40, 10, [createスキル(:連続攻撃)], true)
    モンスター2 = Tモンスター("ミニドラゴン", 50, 10, 5, 10, [createスキル(:連続攻撃)], false)
    モンスター3 = Tモンスター("ミニドラゴン", 50, 10, 5, 10, [createスキル(:連続攻撃)], false)

    描画ツール = create描画ツール()
    モンスター遭遇イベント通知!([モンスター遭遇イベントui処理!], 描画ツール)
    
    プレイヤーs = [プレイヤー1, プレイヤー2, プレイヤー3, プレイヤー4]
    モンスターs = [モンスター1, モンスター2, モンスター3]

    描画ツール.画面更新(戦況表示(プレイヤーs, モンスターs))

    ゲームループ(プレイヤーs, モンスターs, 乱数生成器, 描画ツール)

    if is全滅(モンスターs)
        戦闘勝利イベント通知!([戦闘勝利イベントui処理!], 描画ツール)
    else
        戦闘敗北イベント通知!([戦闘敗北イベントui処理!], 描画ツール)
    end
end
