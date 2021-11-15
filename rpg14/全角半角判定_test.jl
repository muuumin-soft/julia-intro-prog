using Test

include("全角半角判定.jl")

@testset "単一コードポイント" begin
    s = "0020;Na          # Zs         SPACE"
    @testset "正常取得" begin
        @test get_east_asian_width(0x0020, s) == (true, "Na")
    end
    @testset "境界値検査" begin 
        @test get_east_asian_width(0x001F, s) == (false, nothing)
        @test get_east_asian_width(0x0021, s) == (false, nothing)
    end
end

@testset "範囲コードポイント" begin
    s = "0041..005A;Na    # Lu    [26] LATIN CAPITAL LETTER A..LATIN CAPITAL LETTER Z"
    @testset "正常取得" begin
        @test get_east_asian_width(0x0041, s) == (true, "Na")
        @test get_east_asian_width(0x0059, s) == (true, "Na")
        @test get_east_asian_width(0x005A, s) == (true, "Na")
    end
    @testset "境界値検査" begin 
        @test get_east_asian_width(0x0040, s) == (false, nothing)
        @test get_east_asian_width(0x005B, s) == (false, nothing)
    end
end

@testset "ファイルから取得" begin
    @testset "単一コードポイント" begin
        @test get_east_asian_width(0x0020) == "Na"
    end
    @testset "範囲コードポイント" begin
        @test get_east_asian_width(0x00BD) == "A"
    end
end

@testset "eval範囲コードポイント" begin
    s = "0041..005A"
    @test eval範囲コードポイント(s) == 0x0041:0x005A
end

@testset "全角判定byEastAsianWidth特性" begin
    @testset "全角" begin
        @test is全角byEastAsianWidth特性("W") 
        @test is全角byEastAsianWidth特性("F")
        @test is全角byEastAsianWidth特性("A")
    end
    @testset "半角" begin
        @test !is全角byEastAsianWidth特性("Na") 
        @test !is全角byEastAsianWidth特性("N")
        @test !is全角byEastAsianWidth特性("H")
    end
end

@testset "全角半角判定" begin
    @testset "全角" begin
        @test is全角('あ') 
        @test is全角('ア')
        @test is全角('Ａ')
        @test is全角('雨')
        @test is全角('　')
        @test is全角('ー')
    end
    @testset "半角" begin
        @test is半角('a') 
        @test is半角('A')
        @test is半角('1')
        @test is半角('ｱ')
        @test is半角(' ')
        @test is半角('-')
    end
end