include("スキル.jl")

mutable struct Tキャラクター共通データ
    名前
    HP
    最大HP
    MP
    攻撃力
    防御力
    スキルs
    かばっているキャラクター
    かばってくれているキャラクター
    行動前処理イベントリスナーs
    戦闘不能イベントリスナーs
    攻撃実行イベントリスナーs
    回復実行イベントリスナーs
    かばう実行イベントリスナーs
    かばう発動イベントリスナーs
    かばう解除イベントリスナーs
    HP減少イベントリスナーs
    HP回復イベントリスナーs
    攻撃失敗イベントリスナーs
    行動決定イベントリスナーs
    Tキャラクター共通データ(名前, HP, MP, 攻撃力, 防御力, スキルs) = begin
        if HP < 0
            throw(DomainError("HPが負の値になっています"))
        end
        if MP < 0
            throw(DomainError("MPが負の値になっています"))
        end        
        if 攻撃力 < 0
            throw(DomainError("消費MPが負の値になっています"))
        end 
        if 防御力 ≤ 0
            throw(DomainError("防御力が0または負の値になっています"))
        end 
        new(名前, HP, HP, MP, 攻撃力, 防御力, スキルs, nothing, nothing, 
            [getかばう解除!(:行動前処理)], [getかばう解除!(:戦闘不能)], [攻撃実行ui処理!],[回復実行ui処理!],
            [かばう実行ui処理!], [かばう発動ui処理!], [かばう解除ui処理!],
            [HP減少ui処理!], [HP回復ui処理!], [攻撃失敗ui処理!], [行動決定ui処理!])
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

abstract type Tキャラクター end

mutable struct Tプレイヤー <: Tキャラクター
    _キャラクター共通データ::Tキャラクター共通データ
end

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

mutable struct Tモンスター <: Tキャラクター
    _キャラクター共通データ::Tキャラクター共通データ
end

function Tモンスター(名前, HP, MP, 攻撃力, 防御力, スキルs)
    return Tモンスター(Tキャラクター共通データ(名前, HP, MP, 攻撃力, 防御力, スキルs))    
end

function 戦闘不能処理イベント通知!(防御者::Tキャラクター)
    for リスナー in 防御者.戦闘不能イベントリスナーs
        リスナー(防御者)
    end
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

function 行動決定イベント通知!(行動者::Tプレイヤー, プレイヤーs, モンスターs)
    for リスナー in 行動者.行動決定イベントリスナーs
        リスナー(行動者, プレイヤーs, モンスターs)
    end
end
