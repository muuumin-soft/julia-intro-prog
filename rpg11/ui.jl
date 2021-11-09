include("T行動内容.jl")
include("行動系統.jl")
include("Tキャラクター.jl")

function コマンド選択(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    function get対象リスト(スキル::T行動内容)
        get対象リスト(行動系統(スキル))
    end

    function get対象リスト(::T攻撃系行動)
        return モンスターs
    end

    function get対象リスト(::T回復系行動)
        return プレイヤーs
    end

    function get対象リスト(::Tかばう行動)
        return filter(p -> p != 行動者 && isnothing(p.かばってくれているキャラクター), プレイヤーs)
    end

    function get対象リスト(::T刃に毒を塗る行動)
        return [行動者]
    end

    function RadioMenu作成(選択肢)
        while true
            r = RadioMenu(選択肢, pagesize=4)
            選択index = request("選択してください:", r)
    
            if 選択index == -1
                println("正しいコマンドを入力してください")
                continue
            else
                return 選択index
            end
        end
    end

    function 行動対象を選択し行動を決定(行動内容::T行動内容)
        対象リスト = get対象リスト(行動内容)
        if length(対象リスト) == 1
            return T行動(行動内容, 行動者, 対象リスト[1])
        else
            選択index = RadioMenu作成([s.名前 for s in 対象リスト])
            対象者 = 対象リスト[選択index]
            return T行動(行動内容, 行動者, 対象者)
        end
    end

    while true
        選択肢 = ["攻撃", "スキル"]
        選択index = RadioMenu作成(選択肢)
        選択 = 選択肢[選択index]
        if 選択 == "攻撃"
            return 行動対象を選択し行動を決定(T通常攻撃())
        elseif 選択 == "スキル"
            選択index = RadioMenu作成([s.名前 * string(s.消費MP) for s in 行動者.スキルs])
            選択スキル = 行動者.スキルs[選択index]
            if 行動者.MP < 選択スキル.消費MP 
                println("MPが足りません")
                continue
            end
            return 行動対象を選択し行動を決定(選択スキル)
        else
            throw(DomainError("行動選択でありえない選択肢が選ばれています"))
        end
    end 
end

function 戦況表示(プレイヤーs, モンスターs)
    function 表示(c::Tキャラクター)
        s = "$(c.名前) HP:$(c.HP) MP:$(c.MP)"

        状態異常s = c.状態異常s
        if length(状態異常s) > 0
            s *= " " * join(["$(j)" for j in 状態異常s], " ")
        end

        付与s = keys(c.物理攻撃時状態異常付与確率)
        if length(付与s) > 0
            s *= " " * join(["$(f)付与" for f in 付与s], " ")
        end
        return s
    end

    結果 = ["*****プレイヤー*****", 
            join([表示(p) for p in プレイヤーs], "\n"), 
            "*****モンスター*****", 
            join([表示(m) for m in モンスターs], "\n"), 
            "********************"]

    return join(結果, "\n")
end

function 攻撃実行ui処理!(攻撃者, コマンド::T通常攻撃)
    println("----------")
    println("$(攻撃者.名前)の攻撃！")        
end

function 攻撃実行ui処理!(行動者, スキル::Tスキル)
    スキル実行ui処理!(行動者, スキル)
end

function 回復実行ui処理!(行動者, スキル::Tスキル)
    スキル実行ui処理!(行動者, スキル)
end

function スキル実行ui処理!(行動者, スキル::Tスキル)
    println("----------")
    println("$(行動者.名前)の$(スキル.名前)！")
end

function 状態異常付与ui処理!(対象者, 状態異常)
    println("$(対象者.名前)は$(状態異常)状態になった！")
end

function かばう実行ui処理!(行動者, 対象者)
    println("----------")
    println("$(行動者.名前)は$(対象者.名前)を身を呈して守る構えをとった！")        
end

function かばう発動ui処理!(防御者)
    println("$(防御者.かばってくれているキャラクター.名前)が代わりに攻撃を受ける！")
end

function かばう解除ui処理_行動前処理!(行動者, 対象者)
    println("$(行動者.名前)は$(対象者.名前)をかばうのをやめた！")
end

function かばう解除ui処理_戦闘不能!(行動者, 対象者)
    println("$(行動者.名前)は$(対象者.名前)をかばえなくなった！")    
end

function HP減少ui処理!(防御者, 防御者ダメージ)
    println("$(防御者.名前)は$(防御者ダメージ)のダメージを受けた！")
    println("$(防御者.名前)の残りHP：$(防御者.HP)")
end

function HP回復ui処理!(対象者, 回復量)
    println("$(対象者.名前)のHPが$(回復量)回復した！")
    println("$(対象者.名前)の残りHP：$(対象者.HP)")
end

function 攻撃失敗ui処理!()
    println("攻撃は失敗した・・・")
end

function 行動決定ui処理!(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    println(戦況表示(プレイヤーs, モンスターs))
    println("$(行動者.名前)のターン")
end

function モンスター遭遇イベントui処理!()
    println("モンスターに遭遇した！")
    println("戦闘開始！")
end

function 戦闘勝利イベントui処理!()
    println("戦闘に勝利した！")
end

function 戦闘敗北イベントui処理!()
    println("戦闘に敗北した・・・")
end

function 刃に毒を塗る実行ui処理!(対象者)
    println("$(対象者.名前)は刃に毒を塗った！")
end