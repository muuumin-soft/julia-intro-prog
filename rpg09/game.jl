module Game

using Random
import REPL
using REPL.TerminalMenus

include("キャラクター.jl")
include("戦闘.jl")
include("ui.jl")

function main()
    モンスター = Tモンスター("ドラゴン", 400, 80, 40, 10, [createスキル(:連続攻撃)])
    プレイヤー1 = Tプレイヤー("太郎", 100, 20, 10, 10, [createスキル(:連続攻撃), createスキル(:かばう)])
    プレイヤー2 = Tプレイヤー("花子", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:連続攻撃)])
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:かばう)])
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:連続攻撃)])

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