include("スキル.jl")

mutable struct Tキャラクター共通データ
    名前
    HP
    MP
    攻撃力
    防御力
    スキルs
    かばっているキャラクター
    かばってくれているキャラクター
    行動前処理イベントリスナーs
    戦闘不能イベントリスナーs
    攻撃実行イベントリスナーs
    かばう実行イベントリスナーs
    かばう解除イベントリスナーs
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
        new(名前, HP, MP, 攻撃力, 防御力, スキルs, nothing, nothing, 
            [かばう解除!], [かばう解除!], [攻撃実行ui処理!],
            [かばう実行ui処理!], [かばう解除ui処理!])
    end
end

function 攻撃実行イベント通知!(攻撃者, コマンド)
    for リスナー in 攻撃者.攻撃実行イベントリスナーs
        リスナー(攻撃者, コマンド)
    end
end

function かばう実行イベント通知!(行動者, 対象者)
    for リスナー in 行動者.かばう実行イベントリスナーs
        リスナー(行動者, 対象者)
    end
end

function かばう解除イベント通知!(行動者, 対象者)
    for リスナー in 行動者.かばう解除イベントリスナーs
        リスナー(行動者, 対象者)
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
    if 防御者.HP - ダメージ　≤ 0
        防御者.HP = 0
        戦闘不能処理イベント通知!(防御者)
    else
        防御者.HP = 防御者.HP - ダメージ
    end
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