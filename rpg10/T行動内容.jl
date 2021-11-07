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

struct T回復スキル <: Tスキル
    名前
    回復割合
    消費MP
    T回復スキル(名前, 回復割合, 消費MP) = begin
        if !(0 ≤ 回復割合 ≤ 1)
            throw(DomainError("回復割合は0から1の間でなければなりません"))
        end        
        if 消費MP < 0
            throw(DomainError("消費MPが負の値になっています"))
        end 
        new(名前, 回復割合, 消費MP)
    end
end