include("T行動内容.jl")
include("Tキャラクター.jl")

function Tプレイヤー(名前, HP, MP, 攻撃力, 防御力, スキルs)
    return Tプレイヤー(Tキャラクター共通データ(名前, HP, MP, 攻撃力, 防御力, スキルs))    
end

function Base.getproperty(obj::Tキャラクター, sym::Symbol)
    if sym in fieldnames(Tキャラクター共通データ)
        return Base.getproperty(obj._キャラクター共通データ, sym)
    end
    return Base.getfield(obj, sym)
end

function Base.setproperty!(obj::Tキャラクター, sym::Symbol, val)
    if sym in fieldnames(Tキャラクター共通データ)
        return Base.setproperty!(obj._キャラクター共通データ, sym, val)
    end
    return Base.setfield!(obj, sym, val)
end

function Tモンスター(名前, HP, MP, 攻撃力, 防御力, スキルs)
    return Tモンスター(Tキャラクター共通データ(名前, HP, MP, 攻撃力, 防御力, スキルs))    
end

function HP減少!(防御者, ダメージ)
    if ダメージ < 0
        throw(DomainError("ダメージがマイナスです"))
    end

    実際ダメージ = ダメージ < 防御者.HP ? ダメージ : 防御者.HP
    防御者.HP -= 実際ダメージ
    HP減少イベント通知!(防御者, ダメージ)

    if 防御者.HP == 0
        戦闘不能処理イベント通知!(防御者)
    end
end

function HP回復!(対象者, 回復量)
    if 回復量 < 0
        throw(DomainError("回復量がマイナスです"))
    end

    HP減少量 = 対象者.最大HP - 対象者.HP
    実際回復量 = HP減少量 > 回復量 ? 回復量 : HP減少量
    対象者.HP += 実際回復量
    HP回復イベント通知!(対象者, 実際回復量)
end

function MP減少!(行動者, コマンド::T通常攻撃)
end

function MP減少!(行動者, コマンド::Tスキル)
    消費MP = コマンド.消費MP
    if 消費MP < 0
        throw(DomainError("ダメージがマイナスです"))
    end    
    if 行動者.MP - 消費MP　< 0
        行動者.MP = 0
    else
        行動者.MP = 行動者.MP - 消費MP
    end
end

function is行動可能(キャラクター)
    if キャラクター.HP < 0
        throw(DomainError("キャラクターのHPが負です"))
    end
    return キャラクター.HP > 0
end

function 行動可能な奴ら(キャラクターs)
    return [c for c in キャラクターs if is行動可能(c)]
end

function 行動前処理イベント通知!(行動者::Tキャラクター)
    for リスナー in 行動者.行動前処理イベントリスナーs
        リスナー(行動者)        
    end
end

function 行動後処理イベント通知!(行動者::Tキャラクター)
    for リスナー in 行動者.行動後処理イベントリスナーs
        リスナー(行動者)
    end
end

function 戦闘不能処理イベント通知!(防御者::Tキャラクター)
    for リスナー in 防御者.戦闘不能イベントリスナーs
        リスナー(防御者)
    end
end

function 攻撃実行イベント通知!(攻撃者, コマンド)
    for リスナー in 攻撃者.攻撃実行イベントリスナーs
        リスナー(攻撃者, コマンド)
    end
end

function 回復実行イベント通知!(行動者, コマンド)
    for リスナー in 行動者.回復実行イベントリスナーs
        リスナー(行動者, コマンド)
    end
end

function 状態異常付与イベント通知!(対象者, 状態異常)
    for リスナー in 対象者.状態異常付与イベントリスナーs
        リスナー(対象者, 状態異常)
    end
end

function かばう実行イベント通知!(行動者, 対象者)
    for リスナー in 行動者.かばう実行イベントリスナーs
        リスナー(行動者, 対象者)
    end
end

function かばう発動イベント通知!(防御者)
    for リスナー in 防御者.かばう発動イベントリスナーs
        リスナー(防御者)
    end
end

function かばう解除イベント通知!(行動者, 対象者, かばう解除トリガ)
    for リスナー in 行動者.かばう解除イベントリスナーs
        リスナー(行動者, 対象者, かばう解除トリガ)
    end
end

function HP減少イベント通知!(防御者, 防御者ダメージ)
    for リスナー in 防御者.HP減少イベントリスナーs
        リスナー(防御者, 防御者ダメージ)
    end
end

function HP回復イベント通知!(対象者, 回復量)
    for リスナー in 対象者.HP回復イベントリスナーs
        リスナー(対象者, 回復量)
    end
end

function 攻撃失敗イベント通知!(攻撃者)
    for リスナー in 攻撃者.攻撃失敗イベントリスナーs
        リスナー()
    end
end

function 行動決定イベント通知!(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    for リスナー in 行動者.行動決定イベントリスナーs
        リスナー(行動者, プレイヤーs, モンスターs)
    end
end

function 刃に毒を塗る実行イベント通知!(対象者)
    for リスナー in 対象者.刃に毒を塗る実行イベントリスナーs
        リスナー(対象者)
    end
end