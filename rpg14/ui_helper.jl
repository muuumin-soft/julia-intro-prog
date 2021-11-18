include("全角半角判定.jl")

struct 描画ツール
    画面更新
    現在表示行数加算
    ページサイズ
    全角半角判定器
end

function create描画ツール()
    現在表示行数 = 0

    function 画面更新(表示文字列リスト)
        function 消去(行数)
            if 行数 == 0 
                return
            end
            
            print("\x1b[2K") #現在カーソルのある行の文字を消去
            for i in 1:行数+1 #+1はreadlineが作る改行を消すためのもの
                print("\x1b[1F") #カーソルを1行上の先頭に移動
                print("\x1b[2K") #現在カーソルのある行の文字を消去
            end
        end     

        消去(現在表示行数)
        表示文字列リスト = [表示文字列リスト;">>>"] #ユーザーにキー入力を促すための">>>"
        for 文字列 in 表示文字列リスト
            println(文字列)
        end
        現在表示行数 = length(表示文字列リスト)
        readline()
    end

    function 現在表示行数加算(行数)
        現在表示行数 += 行数
    end

    ページサイズ = 4
    return 描画ツール(画面更新, 現在表示行数加算, ページサイズ, create全角半角判定器())
end

function 名前表示調整(名前, 描画ツール)
    function 文字幅(文字)
        if 描画ツール.全角半角判定器.is半角(文字)
            return 1
        elseif 描画ツール.全角半角判定器.is全角(文字)
            return 2
        else 
            throw(ArgumentError("不正な文字です"))
        end
    end
    function 必要な半角スペース(名前)
        最終文字列幅 = 16
        名前文字列幅 = sum(文字幅(x) for x in 名前)
        n = 最終文字列幅 - 名前文字列幅
        return " "^n
    end

    return 名前 * 必要な半角スペース(名前)
end