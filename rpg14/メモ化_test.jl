include("メモ化.jl")

using Test

mutable struct メモ化テスト用構造体
    数値
    配列
end

@testset "メモ化" begin
    @testset "複雑な引数" begin
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

    @testset "可変オブジェクトの中身が変わったとき、不要なメモを参照しないこと" begin
        @testset "通常引数" begin
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
            @testset "可変構造体" begin
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
            @testset "配列中の可変構造体" begin
                function f(arr)
                    s = 0
                    for a in arr
                        s += a.数値 + sum(a.配列) 
                    end
                    return s
                end
                g = メモ化(f)
                a1 = メモ化テスト用構造体(1, [2, 3])
                a2 = メモ化テスト用構造体(4, [5, 6])
                a3 = メモ化テスト用構造体(7, [8, 9])
                arr = [a1, a2, a3]
                @test g(arr) == 45
                a1.数値 = 2 #a1(2, [2, 3])
                @test g(arr) == 46
                a1.配列[1] = 20 #a1(2, [20, 3])
                @test g(arr) == 64
                a1.配列 = [10, 20] #a1(2, [10, 20])
                @test g(arr) == 71
            end
            @testset "辞書中の可変構造体" begin
                function f(dict)
                    s = 0
                    for value in values(dict)
                        s += value.数値 + sum(value.配列) 
                    end
                    return s
                end
                g = メモ化(f)
                dict = Dict()
                dict[:a] = メモ化テスト用構造体(1, [2, 3])
                dict[:b] = メモ化テスト用構造体(4, [5, 6])
                dict[:c] = メモ化テスト用構造体(7, [8, 9])
                @test g(dict) == 45
                dict[:a].数値 = 2 #(2, [2, 3])
                @test g(dict) == 46
                dict[:a].配列[1] = 20 #(2, [20, 3])
                @test g(dict) == 64
                dict[:a].配列 = [10, 20] #a1(2, [10, 20])
                @test g(dict) == 71
            end                
        end
        @testset "キーワード引数" begin
            @testset "配列" begin
                f(;x) = sum(x)
                g = メモ化(f)
                a = [1, 2]
                @test g(x = a) == 3
                push!(a, 3) #[1, 2, 3]
                @test g(x = a) == 6
                a[1] = 10 #[10, 2, 3]
                @test g(x = a) == 15
            end
            @testset "可変構造体" begin
                f(;x) = x.数値 + sum(x.配列)
                g = メモ化(f)
                s = メモ化テスト用構造体(1, [2, 3])
                @test g(x = s) == 6
                s.数値 = 2 #(2, [2, 3])
                @test g(x = s) == 7
                s.配列[1] = 20 #(2, [20, 3])
                @test g(x = s) == 25
                s.配列 = [10, 20] #(2, [10, 20])
                @test g(x = s) == 32
            end
            @testset "配列中の可変構造体" begin
                function f(;arr)
                    s = 0
                    for a in arr
                        s += a.数値 + sum(a.配列) 
                    end
                    return s
                end
                g = メモ化(f)
                a1 = メモ化テスト用構造体(1, [2, 3])
                a2 = メモ化テスト用構造体(4, [5, 6])
                a3 = メモ化テスト用構造体(7, [8, 9])
                arr1 = [a1, a2, a3]
                @test g(;arr = arr1) == 45
                a1.数値 = 2 #a1(2, [2, 3])
                @test g(;arr = arr1) == 46
                a1.配列[1] = 20 #a1(2, [20, 3])
                @test g(;arr = arr1) == 64
                a1.配列 = [10, 20] #a1(2, [10, 20])
                @test g(;arr = arr1) == 71
            end
            @testset "辞書中の可変構造体" begin
                function f(;dict)
                    s = 0
                    for value in values(dict)
                        s += value.数値 + sum(value.配列) 
                    end
                    return s
                end
                g = メモ化(f)
                dict1 = Dict()
                dict1[:a] = メモ化テスト用構造体(1, [2, 3])
                dict1[:b] = メモ化テスト用構造体(4, [5, 6])
                dict1[:c] = メモ化テスト用構造体(7, [8, 9])
                @test g(dict = dict1) == 45
                dict1[:a].数値 = 2 #(2, [2, 3])
                @test g(dict = dict1) == 46
                dict1[:a].配列[1] = 20 #(2, [20, 3])
                @test g(dict = dict1) == 64
                dict1[:a].配列 = [10, 20] #a1(2, [10, 20])
                @test g(dict = dict1) == 71
            end                
        end
    end
end

@testset "@メモ化" begin
    count = 0
    @メモ化 function sum_with_count(a, b...; c, d...)
        count += 1
        return a + sum(b) + c + sum(x.second for x in d)
    end
    @test sum_with_count(1, 2, 3; c = 4, d = 5, e = 6) == 21
    @test count == 1 #初めての呼び出しなので副作用あり
    @test sum_with_count(1, 2, 3; c = 4, d = 5, e = 6) == 21
    @test count == 1 #メモ化が効いているので副作用なし
    @test sum_with_count(1, 2, 3, 7; c = 4, d = 5, e = 6) == 28
    @test count == 2 #別の引数での初めての呼び出しなので副作用あり
    @test sum_with_count(1, 2, 3, 7; c = 4, d = 5, e = 6) == 28
    @test count == 2 #メモ化が効いているので副作用なし
end
