include("メモ化.jl")

using Test

mutable struct メモ化テスト用構造体
    数値
    配列
end

function メモ化用hash(s::メモ化テスト用構造体, hsh::UInt)
    #オブジェクト自体と内部のフィールドも組み合わせてのハッシュ
    h = hsh
    h = Base.hash(s, h)
    h = メモ化用hash(s.数値, h)
    h = メモ化用hash(s.配列, h)
    return h
end

@testset "メモ化" begin
    function func(a, b, c...; d, e, f...)
        s = 0
        s += a
        s += b
        for x in c
            s += x #可変長引数はタプルになるので中身を取得
        end
        s += d
        s += e
        for x in f 
            s += x.second #可変長キーワード引数は、渡された引数名と値でペアのタプルになるので、値を取得
        end
        return s
    end
    m = メモ化(func)
    @test func(1, 2,       d=5, e=6          ) == m(1, 2,       d=5, e=6          ) == 14 #可変長引数なし
    @test func(1, 2, 3,    d=5, e=6, f=7     ) == m(1, 2, 3,    d=5, e=6, f=7     ) == 24 #可変長引数1個
    @test func(1, 2, 3, 4, d=5, e=6, f=7, g=8) == m(1, 2, 3, 4, d=5, e=6, f=7, g=8) == 36 #可変長引数2個

    @testset "可変オブジェクトの中身が変わったとき、不要なメモを参照しないこと" begin
        @testset "配列" begin
            f(x) = sum(x)
            g = メモ化(f)
            a = [1, 2]
            @test g(a) == 3
            push!(a, 3) #[1, 2, 3]
            @test g(a) == 6
            a[1] = 10 #[10, 2, 3]
            @test g(a) == 15
        end
        @testset "構造体" begin
            f(x) = x.数値 + sum(x.配列)
            g = メモ化(f)
            s = メモ化テスト用構造体(1, [2, 3])
            @test g(s) == 6
            s.数値 = 2 #(2, [2, 3])
            @test g(s) == 7
            s.配列[1] = 20 #(2, [20, 3])
            @test g(s) == 25
            s.配列 = [10, 20] #(2, [10, 20])
            @test g(s) == 32
        end
    end
end