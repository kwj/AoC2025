module AoC2025

solutions = [
    "day_01/d01.jl",
    "day_02/d02.jl",
    "day_03/d03.jl",
    "day_04/d04.jl",
    #=
    "day_05/d05.jl",
    "day_06/d06.jl",
    "day_07/d07.jl",
    "day_08/d08.jl",
    "day_09/d09.jl",
    "day_10/d10.jl",
    "day_11/d11.jl",
    "day_12/d12.jl",
    =#
]

for sol in solutions
    include(joinpath(@__DIR__, sol))
end

end # module AoC2025
