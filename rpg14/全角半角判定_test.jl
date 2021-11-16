using Test

include("全角半角判定.jl")

@testset "全角半角判定" begin
    判定器 = create全角半角判定器()
    @testset "全角" begin
        @test 判定器.is全角('あ') 
        @test 判定器.is全角('ア')
        @test 判定器.is全角('Ａ')
        @test 判定器.is全角('雨')
        @test 判定器.is全角('　')
        @test 判定器.is全角('ー')
    end
    @testset "半角" begin
        @test 判定器.is半角('a') 
        @test 判定器.is半角('A')
        @test 判定器.is半角('1')
        @test 判定器.is半角('ｱ')
        @test 判定器.is半角(' ')
        @test 判定器.is半角('-')
    end
end