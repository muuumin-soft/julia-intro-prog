module GameTest

include("ui_stub.jl")
include("乱数.jl")
include("game.jl")
include("全角半角判定_test.jl")

using Test

function createプレイヤー(;名前="太郎", HP=100, MP=20, 攻撃力=10, 防御力=10, スキルs=[])
    return Tプレイヤー(名前, HP, MP, 攻撃力, 防御力, スキルs)
end

function createモンスター(;名前="ドラゴン", HP=400, MP=80, 攻撃力=20, 防御力=10, スキルs=[], isボス=false)
    return Tモンスター(名前, HP, MP, 攻撃力, 防御力, スキルs, isボス)
end

@testset "HP減少" begin

    @testset "ダメージ < HP" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 3, nothing) #3のダメージ
        @test c.HP == 97
    end

    @testset "複数回ダメージ" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 3, nothing) #3のダメージ
        @test c.HP == 97
        HP減少!(c, 3, nothing) #3のダメージ
        @test c.HP == 94
    end   

    @testset "ダメージ > HP" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 101, nothing) #101のダメージ
        @test c.HP == 0
    end

    @testset "ダメージ = HP" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 100, nothing) #100のダメージ
        @test c.HP == 0
    end    
end

@testset "行動実行!" begin
    @testset "通常攻撃" begin
        p = createプレイヤー(HP=100, 攻撃力=10)
        m = createモンスター(HP=200, 攻撃力=20)

        プレイヤーからモンスターへ攻撃 = T行動(T通常攻撃(), p, m)
        行動実行!(プレイヤーからモンスターへ攻撃, get乱数生成器(), nothing)
        @test p.HP == 100
        @test m.HP == 190

        モンスターからプレイヤーへ攻撃 = T行動(T通常攻撃(), m, p)
        行動実行!(モンスターからプレイヤーへ攻撃, get乱数生成器(), nothing)
        @test p.HP == 80
        @test m.HP == 190
    end    

    @testset "大振り攻撃" begin
        p = createプレイヤー(HP=1000, 攻撃力=10)
        m = createモンスター(HP=2000, 攻撃力=20)

        乱数生成器 = get乱数生成器stub()

        プレイヤーからモンスターへ攻撃 = T行動(createスキル(:大振り), p, m)
        for i in 1:4 #40%の確率でヒット
            行動実行!(プレイヤーからモンスターへ攻撃, 乱数生成器, nothing)
            @test p.HP == 1000
            @test m.HP == 2000 - i * 20
        end
        for i in 1:6 #60%の確率で外れる
            行動実行!(プレイヤーからモンスターへ攻撃, 乱数生成器, nothing)
            @test p.HP == 1000
            @test m.HP == 1920
        end

        モンスターからプレイヤーへ攻撃 = T行動(createスキル(:大振り), m, p)
        for i in 1:4 #40%の確率でヒット
            行動実行!(モンスターからプレイヤーへ攻撃, 乱数生成器, nothing)
            @test p.HP == 1000 - i * 40
            @test m.HP == 1920
        end
        for i in 1:6 #60%の確率で外れる
            行動実行!(モンスターからプレイヤーへ攻撃, 乱数生成器, nothing)
            @test p.HP == 840
            @test m.HP == 1920
        end
    end 

    @testset "連続攻撃" begin
        プレイヤーHP = 100
        プレイヤー攻撃力 = 10
        p = createプレイヤー(HP=プレイヤーHP, 攻撃力=プレイヤー攻撃力)
        モンスターHP = 200
        モンスター攻撃力 = 20
        m = createモンスター(HP=モンスターHP, 攻撃力=モンスター攻撃力)

        プレイヤーからモンスターへ攻撃 = T行動(createスキル(:連続攻撃), p, m)
        行動実行!(プレイヤーからモンスターへ攻撃, get乱数生成器(), nothing)
        @test p.HP == プレイヤーHP
        プレイヤー与ダメージ = round(Int, プレイヤー攻撃力/2)
        @test モンスターHP - プレイヤー与ダメージ * 5 ≤ m.HP ≤ モンスターHP - プレイヤー与ダメージ * 2 

        モンスターからプレイヤーへ攻撃 = T行動(createスキル(:連続攻撃), m, p)
        行動実行!(モンスターからプレイヤーへ攻撃, get乱数生成器(), nothing)
        モンスター与ダメージ = round(Int, モンスター攻撃力/2)
        @test プレイヤーHP - モンスター与ダメージ * 5 ≤ p.HP ≤ プレイヤーHP - モンスター与ダメージ * 2 
        @test モンスターHP - プレイヤー与ダメージ * 5 ≤ m.HP ≤ モンスターHP - プレイヤー与ダメージ * 2 
    end 

    @testset "かばう" begin
        @testset "通常攻撃" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)
            ドラゴン = createモンスター(HP=200, 攻撃力=20)

            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう, get乱数生成器(), nothing)

            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃, get乱数生成器(), nothing)
            @test 花子.HP == 100
            @test 太郎.HP == 80 

            行動前処理!(太郎, [花子], [ドラゴン], nothing) #「かばう」が解除される

            行動実行!(ドラゴンから花子へ攻撃, get乱数生成器(), nothing)
            @test 花子.HP == 80
            @test 太郎.HP == 80 
        end

        @testset "連続攻撃" begin
            プレイヤーHP = 100
            太郎 = createプレイヤー(名前="太郎", HP=プレイヤーHP)
            花子 = createプレイヤー(名前="花子", HP=プレイヤーHP)
            モンスター攻撃力 = 20
            ドラゴン = createモンスター(攻撃力=モンスター攻撃力)

            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう, get乱数生成器(), nothing)

            ドラゴンから花子へ連続攻撃 = T行動(createスキル(:連続攻撃), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ連続攻撃, get乱数生成器(), nothing)
            @test 花子.HP == プレイヤーHP
            モンスター与ダメージ = round(Int, モンスター攻撃力/2)
            @test プレイヤーHP - モンスター与ダメージ * 5 ≤ 太郎.HP ≤ プレイヤーHP - モンスター与ダメージ * 2

            行動前処理!(太郎, [花子], [ドラゴン], nothing) #「かばう」が解除される

            行動実行!(ドラゴンから花子へ連続攻撃, get乱数生成器(), nothing)
            @test プレイヤーHP - モンスター与ダメージ * 5 ≤ 花子.HP ≤ プレイヤーHP - モンスター与ダメージ * 2
            @test プレイヤーHP - モンスター与ダメージ * 5 ≤ 太郎.HP ≤ プレイヤーHP - モンスター与ダメージ * 2
        end

        @testset "花子を太郎がかばい、太郎を遠藤君がかばっているとき、太郎がダメージを受ける" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)
            遠藤君 = createプレイヤー(名前="遠藤君", HP=100)
            ドラゴン = createモンスター(HP=200, 攻撃力=20)

            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう, get乱数生成器(), nothing)

            遠藤君が太郎をかばう = T行動(createスキル(:かばう), 遠藤君, 太郎)
            行動実行!(遠藤君が太郎をかばう, get乱数生成器(), nothing)

            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃, get乱数生成器(), nothing)

            @test 花子.HP == 100
            @test 太郎.HP == 80 
            @test 遠藤君.HP == 100
        end

        @testset "かばう実行データチェック" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)

            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう, get乱数生成器(), nothing)

            @test 太郎.かばっているキャラクター == 花子
            @test 花子.かばってくれているキャラクター == 太郎
        end

        @testset "かばう解除データチェック" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)

            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう, get乱数生成器(), nothing)

            行動前処理!(太郎, [花子], [], nothing) #「かばう」が解除される
            @test isnothing(太郎.かばっているキャラクター)
            @test isnothing(花子.かばってくれているキャラクター)
        end

        @testset "戦闘不能になったらかばう解除" begin
            太郎 = createプレイヤー(名前="太郎", HP=40)
            花子 = createプレイヤー(名前="花子", HP=100)
            ドラゴン = createモンスター(HP=200, 攻撃力=20)

            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう, get乱数生成器(), nothing)
            @test 花子.かばってくれているキャラクター == 太郎

            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃, get乱数生成器(), nothing)

            @test 花子.HP == 100
            @test 太郎.HP == 20
            @test 花子.かばってくれているキャラクター == 太郎

            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃, get乱数生成器(), nothing)

            @test 花子.HP == 100
            @test 太郎.HP == 0

            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃, get乱数生成器(), nothing)

            @test 花子.HP == 80
            @test 太郎.HP == 0
        end

        @testset "想定外のシンボルでは例外が発生" begin
            p1 = createプレイヤー()
            p2 = createプレイヤー()
            @test isnothing(かばう解除ui処理!(p1, p2, :行動前処理, nothing))
            @test isnothing(かばう解除ui処理!(p1, p2, :戦闘不能, nothing))
            @test_throws DomainError かばう解除ui処理!(p1, p2, :想定外シンボル, nothing)
        end
    end 

    @testset "ヒール" begin
        @testset "偶数：最大HP以内" begin
            p = createプレイヤー(HP=100)
            HP減少!(p, 51, nothing)
            ヒールで回復 = T行動(createスキル(:ヒール), p, p)
            行動実行!(ヒールで回復, get乱数生成器(), nothing)
            @test p.HP == 100 - 51 + 50                
        end
        @testset "奇数：最大HP以内" begin
            p = createプレイヤー(HP=99)
            HP減少!(p, 51, nothing)
            ヒールで回復 = T行動(createスキル(:ヒール), p, p)
            行動実行!(ヒールで回復, get乱数生成器(), nothing)
            @test p.HP == 99 - 51 + 49             
        end
        @testset "最大HPまで" begin
            p = createプレイヤー(HP=100)
            HP減少!(p, 49, nothing)
            ヒールで回復 = T行動(createスキル(:ヒール), p, p)
            行動実行!(ヒールで回復, get乱数生成器(), nothing)
            @test p.HP == 100                
        end
    end 

    @testset "刃に毒を塗る" begin
        @testset "刃に毒を塗る実行" begin
            p = createプレイヤー()
            刃に毒を塗る = T行動(createスキル(:刃に毒を塗る), p, p)
            行動実行!(刃に毒を塗る, get乱数生成器(), nothing)
            @test p.物理攻撃時状態異常付与確率[:毒] == 0.25    
        end

        @testset "刃に毒を塗ってから通常攻撃実行" begin
            @testset "成功" begin
                p = createプレイヤー()
                刃に毒を塗る = T行動(createスキル(:刃に毒を塗る), p, p)
                行動実行!(刃に毒を塗る, get乱数生成器(), nothing)
        
                m = createモンスター()
                プレイヤーからモンスターへ攻撃 = T行動(T通常攻撃(), p, m)
                乱数生成器 = get乱数生成器stub([0.2]) #25%の確率で状態異常付与なので成功する想定
                行動実行!(プレイヤーからモンスターへ攻撃, 乱数生成器, nothing)
                @test :毒 in m.状態異常s
            end
        
            @testset "失敗" begin
                p = createプレイヤー()
                刃に毒を塗る = T行動(createスキル(:刃に毒を塗る), p, p)
                行動実行!(刃に毒を塗る, get乱数生成器(), nothing)
        
                m = createモンスター()
                プレイヤーからモンスターへ攻撃 = T行動(T通常攻撃(), p, m)
                乱数生成器 = get乱数生成器stub([0.3]) #25%の確率で状態異常付与なので失敗する想定
                行動実行!(プレイヤーからモンスターへ攻撃, 乱数生成器, nothing)
                @test isempty(m.状態異常s)
            end
        end

        @testset "刃に毒を塗ってから通常攻撃実行するもダメージ0" begin
            p = createプレイヤー(攻撃力=0)
            刃に毒を塗る = T行動(createスキル(:刃に毒を塗る), p, p)
            行動実行!(刃に毒を塗る, get乱数生成器(), nothing)
        
            乱数生成器 = get乱数生成器stub()
            for i in 1:10 #ダメージ0なので毒にできない
                m = createモンスター()
                プレイヤーからモンスターへ攻撃 = T行動(T通常攻撃(), p, m)
                行動実行!(プレイヤーからモンスターへ攻撃, 乱数生成器, nothing)
                @test isempty(m.状態異常s)
            end
        end

        @testset "刃に毒を塗ってからスキル攻撃実行" begin
            p = createプレイヤー()
            刃に毒を塗る = T行動(createスキル(:刃に毒を塗る), p, p)
            行動実行!(刃に毒を塗る, get乱数生成器(), nothing)
        
            乱数生成器 = get乱数生成器stub()
            m = createモンスター()
            プレイヤーからモンスターへ攻撃 = T行動(createスキル(:連続攻撃), p, m)
            行動実行!(プレイヤーからモンスターへ攻撃, 乱数生成器, nothing)
            @test :毒 in m.状態異常s
        end

        @testset "毒ダメージ" begin
            @testset "ボス敵：20%ダメージ" begin
                m = createモンスター(HP=100, isボス=true)
                状態異常付与!(m, :毒, nothing)
                行動後処理!(m, nothing, nothing, nothing)
                @test m.HP == 100 - 20
            end
            @testset "ザコ敵：50%ダメージ" begin
                m = createモンスター(HP=100, isボス=false)
                状態異常付与!(m, :毒, nothing)
                行動後処理!(m, nothing, nothing, nothing)
                @test m.HP == 100 - 50
            end
            @testset "プレイヤー：20%ダメージ" begin
                p = createプレイヤー(HP=100)
                状態異常付与!(p, :毒, nothing)
                行動後処理!(p, nothing, nothing, nothing)
                @test p.HP == 100 - 20
            end
        end 
    end     
end

@testset "is戦闘終了" begin
    @testset begin
        @test is戦闘終了([createプレイヤー(HP=1)], [createモンスター(HP=1)]) == false
        @test is戦闘終了([createプレイヤー(HP=1)], [createモンスター(HP=0)]) == true
        @test is戦闘終了([createプレイヤー(HP=0)], [createモンスター(HP=1)]) == true
        @test is戦闘終了([createプレイヤー(HP=0), createプレイヤー(HP=1)], [createモンスター(HP=1)]) == false
        @test is戦闘終了([createプレイヤー(HP=0), createプレイヤー(HP=0)], [createモンスター(HP=1)]) == true
        @test is戦闘終了([createプレイヤー(HP=1)], [createモンスター(HP=0), createモンスター(HP=1)]) == false
        @test is戦闘終了([createプレイヤー(HP=1)], [createモンスター(HP=0), createモンスター(HP=0)]) == true
    end
end

function is全て相異なる(配列)
    if length(配列) == 1
        return true
    elseif length(配列) == 2
        return 配列[1] != 配列[2]
    else
        先頭 = 配列[1]
        残り = 配列[2:end]
        return !(先頭 in 残り) && is全て相異なる(残り) 
    end
end

@testset "is全て相異なる" begin
    #要素数1
    @test is全て相異なる([1]) == true
    #要素数2
    @test is全て相異なる([1, 2]) == true
    @test is全て相異なる([1, 1]) == false
    #要素数3
    @test is全て相異なる([1, 1, 1]) == false    
    @test is全て相異なる([1, 1, 2]) == false
    @test is全て相異なる([1, 2, 1]) == false
    @test is全て相異なる([2, 1, 1]) == false    
    @test is全て相異なる([1, 2, 3]) == true
    @test is全て相異なる([2, 1, 3]) == true
    @test is全て相異なる([3, 2, 1]) == true
end

@testset "行動順決定" begin
    p1 = createプレイヤー()
    m1 = createモンスター()

    @testset "1vs1" begin
        行動順 = 行動順決定([p1], [m1])
        @test length(行動順) == 2
    end

    p2 = createプレイヤー()
    @testset "2vs1" begin
        行動順 = 行動順決定([p1, p2], [m1])
        @test length(行動順) == 3
    end

    m2 = createモンスター()
    @testset "1vs2" begin
        行動順 = 行動順決定([p1], [m1, m2])
        @test length(行動順) == 3
    end

    @testset "2vs2" begin
        行動順 = 行動順決定([p1, p2], [m1, m2])
        @test length(行動順) == 4
    end
end

@testset "is戦闘終了" begin
    @testset "1vs1 両者生存" begin
        p = createプレイヤー(HP=1)
        m = createモンスター(HP=1)
        @test is戦闘終了([p], [m]) == false
    end

    @testset "1vs1 プレイヤー死亡" begin
        p = createプレイヤー(HP=0)
        m = createモンスター(HP=1)
        @test is戦闘終了([p], [m]) == true
    end
end


@testset "is行動可能" begin
    p = createプレイヤー(HP=1)
    @test is行動可能(p) == true
    p = createプレイヤー(HP=0)
    @test is行動可能(p) == false
    m = createモンスター(HP=1)
    @test is行動可能(m) == true
    m = createモンスター(HP=0)
    @test is行動可能(m) == false
end

@testset "行動可能な奴ら" begin
    p1 = createプレイヤー(HP=1)
    @test 行動可能な奴ら([p1]) == [p1]
    p2 = createプレイヤー(HP=0)
    @test 行動可能な奴ら([p1, p2]) == [p1]
    p3 = createプレイヤー(HP=1)
    @test 行動可能な奴ら([p1, p2, p3]) == [p1, p3]

    m1 = createモンスター(HP=1)
    @test 行動可能な奴ら([p1, p2, p3, m1]) == [p1, p3, m1]
    m2 = createモンスター(HP=0)
    @test 行動可能な奴ら([p1, p2, p3, m1, m2]) == [p1, p3, m1]
    m3 = createモンスター(HP=1)
    @test 行動可能な奴ら([p1, p2, p3, m1, m2, m3]) == [p1, p3, m1, m3]
end

@testset "名前表示調整" begin
    判定器 = create全角半角判定器()
    @test 名前表示調整("a", 判定器) == "a               "    
    @test 名前表示調整("ab", 判定器) == "ab              "    
    @test 名前表示調整("あ", 判定器) == "あ              "
    @test 名前表示調整("太郎", 判定器) == "太郎            "
    @test 名前表示調整("tarou", 判定器) == "tarou           "
    @test 名前表示調整("1234567890123456", 判定器) == "1234567890123456"
    @test 名前表示調整("ドラゴン", 判定器) == "ドラゴン        "
    @test 名前表示調整("ドラゴンドラゴン", 判定器) == "ドラゴンドラゴン"
end

end