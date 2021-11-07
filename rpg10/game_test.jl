module GameTest

include("ui.jl")
include("game.jl")

using Test

function createプレイヤー(;名前="太郎", HP=100, MP=20, 攻撃力=10, 防御力=10, スキルs=[])
    return Tプレイヤー(名前, HP, MP, 攻撃力, 防御力, スキルs)
end

function createモンスター(;名前="ドラゴン", HP=400, MP=80, 攻撃力=20, 防御力=10, スキルs=[])
    return Tプレイヤー(名前, HP, MP, 攻撃力, 防御力, スキルs)
end

@testset "HP減少" begin

    @testset "ダメージ < HP" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 3) #3のダメージ
        @test c.HP == 97
    end

    @testset "複数回ダメージ" begin
        c = createプレイヤー(HP=100) 
        HP減少!(c, 3) #3のダメージ
        @test c.HP == 97
        HP減少!(c, 3) #3のダメージ
        @test c.HP == 94
    end   

    @testset "ダメージ > HP" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 101) #101のダメージ
        @test c.HP == 0
    end

    @testset "ダメージ = HP" begin
        c = createプレイヤー(HP=100)
        HP減少!(c, 100) #100のダメージ
        @test c.HP == 0
    end    
end

@testset "行動実行!" begin
    @testset "通常攻撃" begin
        p = createプレイヤー(HP=100, 攻撃力=10)
        m = createモンスター(HP=200, 攻撃力=20)

        プレイヤーからモンスターへ攻撃 = T行動(T通常攻撃(), p, m)
        行動実行!(プレイヤーからモンスターへ攻撃)
        @test p.HP == 100
        @test m.HP == 190

        モンスターからプレイヤーへ攻撃 = T行動(T通常攻撃(), m, p)
        行動実行!(モンスターからプレイヤーへ攻撃)
        @test p.HP == 80
        @test m.HP == 190
    end    

    @testset "大振り攻撃" begin
        p = createプレイヤー(HP=100, 攻撃力=10)
        m = createモンスター(HP=200, 攻撃力=20)

        プレイヤーからモンスターへ攻撃 = T行動(createスキル(:大振り), p, m)
        行動実行!(プレイヤーからモンスターへ攻撃)
        @test p.HP == 100
        @test m.HP == 180 || m.HP == 200

        モンスターからプレイヤーへ攻撃 = T行動(createスキル(:大振り), m, p)
        行動実行!(モンスターからプレイヤーへ攻撃)
        @test p.HP == 100 || p.HP == 60
        @test m.HP == 180 || m.HP == 200
    end 

    @testset "連続攻撃" begin
        p = createプレイヤー(HP=100, 攻撃力=10)
        m = createモンスター(HP=200, 攻撃力=20)

        プレイヤーからモンスターへ攻撃 = T行動(createスキル(:連続攻撃), p, m)
        行動実行!(プレイヤーからモンスターへ攻撃)
        @test p.HP == 100
        @test 200 - 5 * 5 <= m.HP <= 200 - 5 * 2 

        モンスターからプレイヤーへ攻撃 = T行動(createスキル(:連続攻撃), m, p)
        行動実行!(モンスターからプレイヤーへ攻撃)
        @test 100 - 10 * 5 <= p.HP <= 100 - 10 * 2 
        @test 200 - 5 * 5 <= m.HP <= 200 - 5 * 2 
    end 

    @testset "かばう" begin
        @testset "通常攻撃" begin
            太郎 = createプレイヤー(HP=100)
            花子 = createプレイヤー(HP=100)
            ドラゴン = createモンスター(HP=200, 攻撃力=20)
        
            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう)
        
            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃)
            @test 花子.HP == 100
            @test 太郎.HP == 80 

            行動前処理!(太郎, [花子], [ドラゴン]) #「かばう」が解除される
        
            行動実行!(ドラゴンから花子へ攻撃)
            @test 花子.HP == 80
            @test 太郎.HP == 80 
        end

        @testset "連続攻撃" begin
            プレイヤーHP = 100
            プレイヤー攻撃力 = 10
            p = createプレイヤー(HP=プレイヤーHP, 攻撃力=プレイヤー攻撃力)
            モンスターHP = 200
            モンスター攻撃力 = 20
            m = createモンスター(HP=モンスターHP, 攻撃力=モンスター攻撃力)
        
            プレイヤーからモンスターへ攻撃 = T行動(createスキル(:連続攻撃), p, m)
            行動実行!(プレイヤーからモンスターへ攻撃)
            @test p.HP == プレイヤーHP
            @test モンスターHP - プレイヤー攻撃力/2 * 5 ≤ m.HP ≤ モンスターHP - プレイヤー攻撃力/2 * 2 
        
            モンスターからプレイヤーへ攻撃 = T行動(createスキル(:連続攻撃), m, p)
            行動実行!(モンスターからプレイヤーへ攻撃)
            @test プレイヤーHP - モンスター攻撃力/2 * 5 <= p.HP <= プレイヤーHP - モンスター攻撃力/2 * 2 
            @test モンスターHP - プレイヤー攻撃力/2 * 5 ≤ m.HP ≤ モンスターHP - プレイヤー攻撃力/2 * 2 
        end 

        @testset "花子を太郎がかばい、太郎を遠藤君がかばっているとき、太郎がダメージを受ける" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)
            遠藤君 = createプレイヤー(名前="遠藤君", HP=100)
            ドラゴン = createモンスター(HP=200, 攻撃力=20)
        
            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう)
        
            遠藤君が太郎をかばう = T行動(createスキル(:かばう), 遠藤君, 太郎)
            行動実行!(遠藤君が太郎をかばう)
        
            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃)
        
            @test 花子.HP == 100
            @test 太郎.HP == 80 
            @test 遠藤君.HP == 100
        end

        @testset "かばう実行データチェック" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)
        
            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう)
        
            @test 太郎.かばっているキャラクター == 花子
            @test 花子.かばってくれているキャラクター == 太郎
        end

        @testset "かばう解除データチェック" begin
            太郎 = createプレイヤー(名前="太郎", HP=100)
            花子 = createプレイヤー(名前="花子", HP=100)
        
            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう)
        
            行動前処理!(太郎, [花子], []) #「かばう」が解除される
            @test isnothing(太郎.かばっているキャラクター)
            @test isnothing(花子.かばってくれているキャラクター)
        end

        @testset "戦闘不能になったらかばう解除" begin
            太郎 = createプレイヤー(名前="太郎", HP=40)
            花子 = createプレイヤー(名前="花子", HP=100)
            ドラゴン = createモンスター(HP=200, 攻撃力=20)
        
            太郎が花子をかばう = T行動(createスキル(:かばう), 太郎, 花子)
            行動実行!(太郎が花子をかばう)
            @test 花子.かばってくれているキャラクター == 太郎
        
            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃)
        
            @test 花子.HP == 100
            @test 太郎.HP == 20
            @test 花子.かばってくれているキャラクター == 太郎
        
            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃)
        
            @test 花子.HP == 100
            @test 太郎.HP == 0
        
            ドラゴンから花子へ攻撃 = T行動(T通常攻撃(), ドラゴン, 花子)
            行動実行!(ドラゴンから花子へ攻撃)
        
            @test 花子.HP == 80
            @test 太郎.HP == 0
        end
    end 

    @testset "ヒール" begin
        @testset "偶数：最大HP以内" begin
            p = createプレイヤー(HP=100)
            HP減少!(p, 51)
            ヒールで回復 = T行動(createスキル(:ヒール), p, p)
            行動実行!(ヒールで回復)
            @test p.HP == 100 - 51 + 50                
        end
        @testset "奇数：最大HP以内" begin
            p = createプレイヤー(HP=99)
            HP減少!(p, 51)
            ヒールで回復 = T行動(createスキル(:ヒール), p, p)
            行動実行!(ヒールで回復)
            @test p.HP == 99 - 51 + 49             
        end
        @testset "最大HPまで" begin
            p = createプレイヤー(HP=100)
            HP減少!(p, 49)
            ヒールで回復 = T行動(createスキル(:ヒール), p, p)
            行動実行!(ヒールで回復)
            @test p.HP == 100                
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

@testset "戦況表示" begin
    モンスター = Tモンスター("ドラゴン", 400, 80, 40, 10, [])
    プレイヤー1 = Tプレイヤー("太郎", 100, 20, 10, 10, [])
    プレイヤー2 = Tプレイヤー("花子", 100, 20, 10, 10, [])
    プレイヤー3 = Tプレイヤー("遠藤君", 100, 20, 10, 10, [])
    プレイヤー4 = Tプレイヤー("高橋先生", 100, 20, 10, 10, [])
    プレイヤーs = [プレイヤー1, プレイヤー2, プレイヤー3, プレイヤー4]
    モンスターs = [モンスター]

    @test 戦況表示(プレイヤーs, モンスターs) == 
    """
    *****プレイヤー*****
    太郎 HP:100 MP:20
    花子 HP:100 MP:20
    遠藤君 HP:100 MP:20
    高橋先生 HP:100 MP:20
    *****モンスター*****
    ドラゴン HP:400 MP:80
    ********************"""
end

end