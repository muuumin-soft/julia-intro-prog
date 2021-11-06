module Game

using Random
import REPL
using REPL.TerminalMenus

include("キャラクター.jl")
include("戦闘.jl")
include("ui.jl")

function モンスター遭遇イベント通知!(リスナーs)
    for リスナー in リスナーs
        リスナー()
    end
end

function 戦闘勝利イベント通知!(リスナーs)
    for リスナー in リスナーs
        リスナー()
    end
end

function 戦闘敗北イベント通知!(リスナーs)
    for リスナー in リスナーs
        リスナー()
    end
end

function main()
    モンスター = Tモンスター("ドラゴン", 400, 80, 40, 10, [createスキル(:連続攻撃)])
    プレイヤー1 = Tプレイヤー("太郎", 100, 20, 10, 10, [createスキル(:連続攻撃), createスキル(:かばう)])
    プレイヤー2 = Tプレイヤー("花子", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:連続攻撃)])
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:かばう)])
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:連続攻撃)])

    モンスター遭遇イベント通知!([モンスター遭遇イベントui処理!])

    ゲームループ([プレイヤー1, プレイヤー2, プレイヤー3, プレイヤー4], [モンスター])

    if モンスター.HP == 0
        戦闘勝利イベント通知!([戦闘勝利イベントui処理!])
    else
        戦闘敗北イベント通知!([戦闘敗北イベントui処理!])
    end
end

end