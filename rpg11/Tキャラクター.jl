mutable struct Tキャラクター共通データ
    名前
    HP
    最大HP
    MP
    攻撃力
    防御力
    状態異常s
    物理攻撃時状態異常付与確率
    スキルs
    かばっているキャラクター
    かばってくれているキャラクター
    行動前処理イベントリスナーs
    行動後処理イベントリスナーs
    戦闘不能イベントリスナーs
    攻撃実行イベントリスナーs
    回復実行イベントリスナーs
    状態異常付与イベントリスナーs
    かばう実行イベントリスナーs
    かばう発動イベントリスナーs
    かばう解除イベントリスナーs
    HP減少イベントリスナーs
    HP回復イベントリスナーs
    攻撃失敗イベントリスナーs
    行動決定イベントリスナーs
    刃に毒を塗る実行イベントリスナーs
    毒ダメージ発生イベントリスナーs
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
        new(名前, HP, HP, MP, 攻撃力, 防御力, Set(),　Dict(), スキルs, nothing, nothing, 
            [getかばう解除!(:行動前処理)], [毒ダメージ発生!], [getかばう解除!(:戦闘不能)], 
            [攻撃実行ui処理!],[回復実行ui処理!],[状態異常付与ui処理!],
            [かばう実行ui処理!], [かばう発動ui処理!], [かばう解除ui処理!],
            [HP減少ui処理!], [HP回復ui処理!], [攻撃失敗ui処理!], [行動決定ui処理!],
            [刃に毒を塗る実行ui処理!], [毒ダメージ発生ui処理!])
    end
end

abstract type Tキャラクター end

mutable struct Tプレイヤー <: Tキャラクター
    _キャラクター共通データ::Tキャラクター共通データ
end

mutable struct Tモンスター <: Tキャラクター
    _キャラクター共通データ::Tキャラクター共通データ
    isボス
end

function getかばう解除!(かばう解除トリガ)
    return function かばう解除!(行動者)
        if !isnothing(行動者.かばっているキャラクター)
            対象者 = 行動者.かばっているキャラクター
            かばう解除イベント通知!(行動者, 対象者, かばう解除トリガ)
            行動者.かばっているキャラクター = nothing                    
            対象者.かばってくれているキャラクター = nothing
            #事後条件
            かばうデータ整合性チェック(行動者)
            かばうデータ整合性チェック(対象者)
        end
    end
end