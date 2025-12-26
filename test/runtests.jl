using AoC2025
using Test

# read test cases for solutions
include.(filter(contains(r"tc.*.jl$"), readdir("./")))
