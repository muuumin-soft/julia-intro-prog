include("T行動内容.jl")
include("Tキャラクター.jl")

function 攻撃実行ui処理!(攻撃者, コマンド::T通常攻撃) end
function 攻撃実行ui処理!(行動者, スキル::Tスキル) end
function 回復実行ui処理!(行動者, スキル::Tスキル) end
function スキル実行ui処理!(行動者, スキル::Tスキル) end
function かばう実行ui処理!(行動者, 対象者) end
function かばう発動ui処理!(防御者) end
function かばう解除ui処理_行動前処理!(行動者, 対象者) end
function かばう解除ui処理_戦闘不能!(行動者, 対象者) end
function HP減少ui処理!(防御者, 防御者ダメージ) end
function HP回復ui処理!(対象者, 回復量) end
function 攻撃失敗ui処理!() end
function 行動決定ui処理!(行動者::Tプレイヤー, プレイヤーs, モンスターs) end
