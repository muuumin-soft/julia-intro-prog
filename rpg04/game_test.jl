include("game.jl")

using Test

@testset "HP減少" begin
    function createキャラクターHP100()
        return Game.Tプレイヤー("", 100, 0, 0)
    end

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