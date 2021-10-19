abstract type Tスキル end

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

struct T通常攻撃 end

function createスキル(スキルシンボル)
    if スキルシンボル == :大振り
        return T攻撃スキル("大振り", 2, 0.4, 0)
    elseif スキルシンボル == :連続攻撃
        return T攻撃スキル("連続攻撃", 0.5, 1, 10, 2, 5)
    else
        Throw(DomainError("未定義のスキルが指定されました"))
    end
end