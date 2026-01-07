# test cases for example inputs on Advent of Code 2025

# I also placed the example inputs shown in the problem statements in separate
# files such as `input0`, `input1`, etc.
#
# For example:
#
# $ ls ./day_01
# d01.jl  input  input0
#
# Of course, input files can be freely named. These examples are my taste.

@testset verbose = true "Advent of Code 2025 (examples)" begin
    @testset "Day 1 / Part 1" begin
        @test d01_p1("input0") == 3
    end
    @testset "Day 1 / Part 2" begin
        @test d01_p2("input0") == 6
    end

    @testset "Day 2 / Part 1" begin
        @test d02_p1("input0") == 1227775554
    end
    @testset "Day 2 / Part 2" begin
        @test d02_p2("input0") == 4174379265
    end

    @testset "Day 3 / Part 1" begin
        @test d03_p1("input0") == 357
    end
    @testset "Day 3 / Part 2" begin
        @test d03_p2("input0") == 3121910778619
    end

    @testset "Day 4 / Part 1" begin
        @test d04_p1("input0") == 13
    end
    @testset "Day 4 / Part 2" begin
        @test d04_p2("input0") == 43
    end

    @testset "Day 5 / Part 1" begin
        @test d05_p1("input0") == 3
    end
    @testset "Day 5 / Part 2" begin
        @test d05_p2("input0") == 14
    end

    @testset "Day 6 / Part 1" begin
        @test d06_p1("input0") == 4277556
    end
    @testset "Day 6 / Part 2" begin
        @test d06_p2("input0") == 3263827
    end

    @testset "Day 7 / Part 1" begin
        @test d07_p1("input0") == 21
    end
    @testset "Day 7 / Part 2" begin
        @test d07_p2("input0") == 40
    end

    @testset "Day 8 / Part 1" begin
        @test d08_p1("input0", thr = 10) == 40
    end
    @testset "Day 8 / Part 2" begin
        @test d08_p2("input0") == 25272
    end

    @testset "Day 9 / Part 1" begin
        @test d09_p1("input0") == 50
    end
    @testset "Day 9 / Part 2" begin
        @test d09_p2("input0") == 24
    end

    @testset "Day 10 / Part 1" begin
        @test d10_p1("input0") == 7
    end
    @testset "Day 10 / Part 2" begin
        @test d10_p2("input0") == 33
    end

    @testset "Day 11 / Part 1" begin
        @test d11_p1("input0") == 5
    end
    @testset "Day 11 / Part 2" begin
        @test d11_p2("input1") == 2
    end
end
