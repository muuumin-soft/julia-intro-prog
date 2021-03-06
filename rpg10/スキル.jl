include("T行動内容.jl")

function T攻撃スキル(名前, 威力, 命中率, 消費MP) 
    return T攻撃スキル(名前, 威力, 命中率, 消費MP, 1, 1)
end

function T刃に毒を塗る() 
    return T刃に毒を塗る("刃に毒を塗る", 5)
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
    elseif スキルシンボル === :刃に毒を塗る
        return T刃に毒を塗る()
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

#関数名が紛らわしいが、「かばうを解除する時にメッセージを出し分けたい」という
#モデルの処理なのでUI層ではなくモデル層に定義
function かばう解除ui処理!(行動者, 対象者, かばう解除トリガ)
    if かばう解除トリガ === :行動前処理
        かばう解除ui処理_行動前処理!(行動者, 対象者)
    elseif かばう解除トリガ === :戦闘不能
        かばう解除ui処理_戦闘不能!(行動者, 対象者)
    else
        throw(DomainError("想定していないトリガでかばうが解除されました"))
    end
end