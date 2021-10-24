include("game.jl")

using Test

function createキャラクターHP100()
    return Game.Tプレイヤー("", 100, 0, 1, 10, [])
end

function createプレイヤーHP100攻撃力10()
    return Game.Tプレイヤー("", 100, 0, 10, 10, [])
end

function createモンスターHP200攻撃力20()
    return Game.Tモンスター("", 200, 0, 20, 10, [])
end

function createプレイヤーHP0()
    return Game.Tプレイヤー("", 0, 0, 1, 1, [])
end

function createプレイヤーHP1()
    return Game.Tプレイヤー("", 1, 0, 1, 1, [])
end

function createモンスターHP0()
    return Game.Tモンスター("", 0, 0, 1, 1, [])
end

function createモンスターHP1()
    return Game.Tモンスター("", 1, 0, 1, 1, [])
end

function createプレイヤー()
    return Game.Tプレイヤー("", 0, 0, 1, 1, [])
end

function createモンスター()
    return Game.Tモンスター("", 0, 0, 1, 1, [])
end

function createプレイヤーHP(HP)
    return Game.Tプレイヤー("", HP, 0, 1, 1, [])
end

function createモンスターHP(HP)
    return Game.Tモンスター("", HP, 0, 1, 1, [])
end

@testset "HP減少" begin

    @testset "ダメージ < HP" begin
        c = createキャラクターHP100()
        Game.HP減少!(c, 3) #3のダメージ
        @test c.HP == 97
    end

    @testset "複数回ダメージ" begin
        c = createキャラクターHP100() 
        Game.HP減少!(c, 3) #3のダメージ
        @test c.HP == 97
        Game.HP減少!(c, 3) #3のダメージ
        @test c.HP == 94
    end   

    @testset "ダメージ > HP" begin
        c = createキャラクターHP100() 
        Game.HP減少!(c, 101) #101のダメージ
        @test c.HP == 0
    end

    @testset "ダメージ = HP" begin
        c = createキャラクターHP100() 
        Game.HP減少!(c, 100) #100のダメージ
        @test c.HP == 0
    end    
end

@testset "行動実行!" begin
    @testset "通常攻撃" begin
        p = createプレイヤーHP100攻撃力10()
        m = createモンスターHP200攻撃力20()

        プレイヤーからモンスターへ攻撃 = Game.T行動(Game.T通常攻撃(), p, m)
        Game.行動実行!(プレイヤーからモンスターへ攻撃)
        @test p.HP == 100
        @test m.HP == 190

        モンスターからプレイヤーへ攻撃 = Game.T行動(Game.T通常攻撃(), m, p)
        Game.行動実行!(モンスターからプレイヤーへ攻撃)
        @test p.HP == 80
        @test m.HP == 190
    end    

    @testset "大振り攻撃" begin
        p = createプレイヤーHP100攻撃力10()
        m = createモンスターHP200攻撃力20()

        プレイヤーからモンスターへ攻撃 = Game.T行動(Game.createスキル(:大振り), p, m)
        Game.行動実行!(プレイヤーからモンスターへ攻撃)
        @test p.HP == 100
        @test m.HP == 180 || m.HP == 200

        モンスターからプレイヤーへ攻撃 = Game.T行動(Game.createスキル(:大振り), m, p)
        Game.行動実行!(モンスターからプレイヤーへ攻撃)
        @test p.HP == 100 || p.HP == 60
        @test m.HP == 180 || m.HP == 200
    end 

    @testset "連続攻撃" begin
        p = createプレイヤーHP100攻撃力10()
        m = createモンスターHP200攻撃力20()

        プレイヤーからモンスターへ攻撃 = Game.T行動(Game.createスキル(:連続攻撃), p, m)
        Game.行動実行!(プレイヤーからモンスターへ攻撃)
        @test p.HP == 100
        @test 200 - 5 * 5 <= m.HP <= 200 - 5 * 2 

        モンスターからプレイヤーへ攻撃 = Game.T行動(Game.createスキル(:連続攻撃), m, p)
        Game.行動実行!(モンスターからプレイヤーへ攻撃)
        @test 100 - 10 * 5 <= p.HP <= 100 - 10 * 2 
        @test 200 - 5 * 5 <= m.HP <= 200 - 5 * 2 
    end 

    @testset "かばう" begin
        @testset "通常攻撃" begin
            太郎 = createキャラクターHP100()
            花子 = createキャラクターHP100()
            ドラゴン = createモンスターHP200攻撃力20()
        
            太郎が花子をかばう = Game.T行動(Game.createスキル(:かばう), 太郎, 花子)
            Game.行動実行!(太郎が花子をかばう)
        
            ドラゴンから花子へ攻撃 = Game.T行動(Game.T通常攻撃(), ドラゴン, 花子)
            Game.行動実行!(ドラゴンから花子へ攻撃)
            @test 花子.HP == 100
            @test 太郎.HP == 80 

            Game.行動前処理!(太郎, [花子], [ドラゴン]) #「かばう」が解除される
        
            Game.行動実行!(ドラゴンから花子へ攻撃)
            @test 花子.HP == 80
            @test 太郎.HP == 80 
        end

        @testset "連続攻撃" begin
            太郎 = createキャラクターHP100()
            花子 = createキャラクターHP100()
            ドラゴン = createモンスターHP200攻撃力20()
    
            太郎が花子をかばう = Game.T行動(Game.createスキル(:かばう), 太郎, 花子)
            Game.行動実行!(太郎が花子をかばう)
    
            ドラゴンから花子へ連続攻撃 = Game.T行動(Game.createスキル(:連続攻撃), ドラゴン, 花子)
            Game.行動実行!(ドラゴンから花子へ連続攻撃)
            @test 花子.HP == 100
            @test 100 - 10 * 5 <= 太郎.HP <= 100 - 10 * 2
    
            Game.行動前処理!(太郎, [花子], [ドラゴン]) #「かばう」が解除される
    
            Game.行動実行!(ドラゴンから花子へ連続攻撃)
            @test 100 - 10 * 5 <= 花子.HP <= 100 - 10 * 2
            @test 100 - 10 * 5 <= 太郎.HP <= 100 - 10 * 2
        end
    end 
end

@testset "is戦闘終了" begin
    @testset begin
        @test Game.is戦闘終了([createプレイヤーHP1()], [createモンスターHP1()]) == false
        @test Game.is戦闘終了([createプレイヤーHP1()], [createモンスターHP0()]) == true
        @test Game.is戦闘終了([createプレイヤーHP0()], [createモンスターHP1()]) == true
        @test Game.is戦闘終了([createプレイヤーHP0(), createプレイヤーHP1()], [createモンスターHP1()]) == false
        @test Game.is戦闘終了([createプレイヤーHP0(), createプレイヤーHP0()], [createモンスターHP1()]) == true
        @test Game.is戦闘終了([createプレイヤーHP1()], [createモンスターHP0(), createモンスターHP1()]) == false
        @test Game.is戦闘終了([createプレイヤーHP1()], [createモンスターHP0(), createモンスターHP0()]) == true
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
        行動順 = Game.行動順決定([p1], [m1])
        @test length(行動順) == 2
    end

    p2 = createプレイヤー()
    @testset "2vs1" begin
        行動順 = Game.行動順決定([p1, p2], [m1])
        @test length(行動順) == 3
    end

    m2 = createモンスター()
    @testset "1vs2" begin
        行動順 = Game.行動順決定([p1], [m1, m2])
        @test length(行動順) == 3
    end

    @testset "2vs2" begin
        行動順 = Game.行動順決定([p1, p2], [m1, m2])
        @test length(行動順) == 4
    end
end

@testset "is戦闘終了" begin
    @testset "1vs1 両者生存" begin
        p = createプレイヤーHP1()
        m = createモンスターHP1()
        @test Game.is戦闘終了([p], [m]) == false
    end

    @testset "1vs1 プレイヤー死亡" begin
        p = createプレイヤーHP0()
        m = createモンスターHP1()
        @test Game.is戦闘終了([p], [m]) == true
    end
end


@testset "is行動可能" begin
    p = createプレイヤーHP1()
    @test Game.is行動可能(p) == true
    p = createプレイヤーHP0()
    @test Game.is行動可能(p) == false
    m = createモンスターHP1()
    @test Game.is行動可能(m) == true
    m = createモンスターHP0()
    @test Game.is行動可能(m) == false
end

@testset "行動可能な奴ら" begin
    p1 = createプレイヤーHP1()
    @test Game.行動可能な奴ら([p1]) == [p1]
    p2 = createプレイヤーHP0()
    @test Game.行動可能な奴ら([p1, p2]) == [p1]
    p3 = createプレイヤーHP1()
    @test Game.行動可能な奴ら([p1, p2, p3]) == [p1, p3]

    m1 = createモンスターHP1()
    @test Game.行動可能な奴ら([p1, p2, p3, m1]) == [p1, p3, m1]
    m2 = createモンスターHP0()
    @test Game.行動可能な奴ら([p1, p2, p3, m1, m2]) == [p1, p3, m1]
    m3 = createモンスターHP1()
    @test Game.行動可能な奴ら([p1, p2, p3, m1, m2, m3]) == [p1, p3, m1, m3]
end

@testset "戦況表示" begin
    モンスター = Game.Tモンスター("ドラゴン", 400, 80, 40, 10, [])
    プレイヤー1 = Game.Tプレイヤー("太郎", 100, 20, 10, 10, [])
    プレイヤー2 = Game.Tプレイヤー("花子", 100, 20, 10, 10, [])
    プレイヤー3 = Game.Tプレイヤー("遠藤君", 100, 20, 10, 10, [])
    プレイヤー4 = Game.Tプレイヤー("高橋先生", 100, 20, 10, 10, [])
    プレイヤーs = [プレイヤー1, プレイヤー2, プレイヤー3, プレイヤー4]
    モンスターs = [モンスター]

    @test Game.戦況表示(プレイヤーs, モンスターs) == 
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


