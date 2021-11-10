using Random
import REPL
using REPL.TerminalMenus

include("スキル.jl")
include("キャラクター.jl")
include("戦闘.jl")

function create画面更新関数()
    現在表示行数 = 0

    function 画面更新(表示文字列リスト)
        function 消去(行数)
            if 行数 == 0 
                return
            end
            
            print("\x1b[2K") #現在カーソルのある行の文字を消去
            for i in 1:行数+1 #+1はreadlineが作る改行を消すためのもの
                print("\x1b[1F") #カーソルを1行上の先頭に移動
                print("\x1b[2K") #現在カーソルのある行の文字を消去
            end
        end     

        消去(現在表示行数)
        for 文字列 in 表示文字列リスト
            println(文字列)
        end
        現在表示行数 = length(表示文字列リスト)
        readline()
    end
end

function モンスター遭遇イベント通知!(リスナーs, 画面更新関数)
    for リスナー in リスナーs
        リスナー(画面更新関数)
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

function main(乱数生成器)
    プレイヤー1 = Tプレイヤー("太郎", 100, 20, 10, 10, [createスキル(:連続攻撃), createスキル(:かばう), createスキル(:ヒール), createスキル(:刃に毒を塗る)])
    プレイヤー2 = Tプレイヤー("花子", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:連続攻撃)])
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 20, 10, 10, [createスキル(:大振り), createスキル(:かばう)])
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 20, 10, 10, [createスキル(:ヒール), createスキル(:連続攻撃)])

    モンスター1 = Tモンスター("ボスドラゴン", 400, 80, 40, 10, [createスキル(:連続攻撃)], true)
    モンスター2 = Tモンスター("ミニドラゴン", 50, 10, 5, 10, [createスキル(:連続攻撃)], false)
    モンスター3 = Tモンスター("ミニドラゴン", 50, 10, 5, 10, [createスキル(:連続攻撃)], false)

    画面更新関数 = create画面更新関数()
    モンスター遭遇イベント通知!([モンスター遭遇イベントui処理!], 画面更新関数)
    
    プレイヤーs = [プレイヤー1, プレイヤー2, プレイヤー3, プレイヤー4]
    モンスターs = [モンスター1, モンスター2, モンスター3]

    #=
    ゲームループ(プレイヤーs, モンスターs, 乱数生成器)

    if is全滅(モンスターs)
        戦闘勝利イベント通知!([戦闘勝利イベントui処理!])
    else
        戦闘敗北イベント通知!([戦闘敗北イベントui処理!])
    end
    =#
end
