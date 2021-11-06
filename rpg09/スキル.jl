abstract type T行動内容 end 
abstract type Tスキル <: T行動内容　end 
struct T通常攻撃 <: T行動内容 end

struct Tかばう <: Tスキル 
    名前
    消費MP
end

struct T攻撃スキル <: Tスキル
    名前
    威力
    命中率
    消費MP
    攻撃回数min
    攻撃回数max
    T攻撃スキル(名前, 威力, 命中率, 消費MP, 攻撃回数min, 攻撃回数max) = begin
        if 威力 < 0
            throw(DomainError("威力が負の値になっています"))
        end
        if !(0 ≤ 命中率 ≤ 1)
            throw(DomainError("命中率は0から1の間でなければなりません"))
        end        
        if 消費MP < 0
            throw(DomainError("消費MPが負の値になっています"))
        end 
        if 攻撃回数min < 0
            throw(DomainError("攻撃回数minが負の値になっています"))
        end 
        if 攻撃回数max < 0
            throw(DomainError("攻撃回数maxが負の値になっています"))
        end 
        if 攻撃回数max < 攻撃回数min 
            throw(DomainError("攻撃回数maxが攻撃回数minより小さくなっています"))
        end 
        new(名前, 威力, 命中率, 消費MP, 攻撃回数min, 攻撃回数max)  
    end
end

function T攻撃スキル(名前, 威力, 命中率, 消費MP) 
    return T攻撃スキル(名前, 威力, 命中率, 消費MP, 1, 1)
end

function createスキル(スキルシンボル)
    if スキルシンボル == :大振り
        return T攻撃スキル("大振り", 2, 0.4, 0)
    elseif スキルシンボル == :連続攻撃
        return T攻撃スキル("連続攻撃", 0.5, 1, 10, 2, 5)
    elseif スキルシンボル === :かばう
        return Tかばう("かばう", 0)
    else
        Throw(DomainError("未定義のスキルが指定されました"))
    end
end

function かばう実行!(行動者, 対象者)
    かばう実行イベント通知!(行動者, 対象者)
    行動者.かばっているキャラクター = 対象者
    対象者.かばってくれているキャラクター = 行動者

    #事後条件
    かばうデータ整合性チェック(行動者)
    かばうデータ整合性チェック(対象者)
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

function かばうデータ整合性チェック(キャラクター)
    if !isnothing(キャラクター.かばっているキャラクター)
        if (キャラクター.かばっているキャラクター.かばってくれているキャラクター != キャラクター)
            throw(DomainError("$(キャラクター.名前)の「かばう」データに不整合が発生しています"))
        end
    end

    if !isnothing(キャラクター.かばってくれているキャラクター)
        if (キャラクター.かばってくれているキャラクター.かばっているキャラクター != キャラクター)
            throw(DomainError("$(キャラクター.名前)の「かばう」データに不整合が発生しています"))
        end
    end
end
