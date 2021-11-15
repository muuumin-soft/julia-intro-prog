include("T行動内容.jl")
include("Tキャラクター.jl")
include("ui_helper.jl")


function 攻撃実行ui処理!(攻撃者, コマンド::T通常攻撃, 描画ツール) end
function 攻撃実行ui処理!(行動者, スキル::Tスキル, 描画ツール) end
function 回復実行ui処理!(行動者, スキル::Tスキル, 描画ツール) end
function スキル実行ui処理!(行動者, スキル::Tスキル, 描画ツール) end
function 状態異常付与ui処理!(対象者, 状態異常, 描画ツール) end
function かばう実行ui処理!(行動者, 対象者, 描画ツール) end
function かばう発動ui処理!(防御者, 描画ツール) end
function かばう解除ui処理_行動前処理!(行動者, 対象者, 描画ツール) end
function かばう解除ui処理_戦闘不能!(行動者, 対象者, 描画ツール) end
function HP減少ui処理!(防御者, 防御者ダメージ, 描画ツール) end
function HP回復ui処理!(対象者, 回復量, 描画ツール) end
function 攻撃失敗ui処理!(描画ツール) end
function 行動決定ui処理!(行動者::Tプレイヤー, プレイヤーs, モンスターs, 描画ツール) end
function 刃に毒を塗る実行ui処理!(対象者, 描画ツール) end
function 毒ダメージ発生ui処理!(対象者, 描画ツール) end