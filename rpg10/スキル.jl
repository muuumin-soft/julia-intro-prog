include("T行動内容.jl")

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
    elseif スキルシンボル === :ヒール
        return T回復スキル("ヒール", 0.5, 10)
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
