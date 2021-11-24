include("メモ化.jl")

using Test


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
end