
module Day12

#=
Note: This solution is NOT general purpose.

Based on my given data, all the presents fitted within a 3x3 space.
I therefore carried out a preliminary investigation.
Then, unexpectedly, I found the answer.
=#

function parse_file(fname::String)
    present_data..., region_data = split(readchomp(joinpath(@__DIR__, fname)), "\n\n")

    presents = Vector{Tuple{Int, Matrix{Int}}}()
    foreach(present_data) do p
        _, shape = split(p, ":\n")
        grid = stack(map.(ch -> ch == '#' ? 1 : 0, collect.(split(shape, "\n"))), dims = 1)
        push!(presents, (sum(grid), grid))
    end

    regions = map(split(region_data, "\n")) do line
        ns = parse.(Int, split(line, !isnumeric, keepempty = false))
        (ns[1], ns[2]), ns[3:end]
    end

    presents, regions
end

function d12_p1(fname::String = "input")
    presents, regions = parse_file(fname)
    @assert all(x -> size(x[2]) == (3, 3), presents) "invalid shape"

    possible, impossible, uncertain = 0, 0, 0
    pops = map(first, presents)
    q = Vector{Int}()

    for (idx, ((x, y), qtys)) in pairs(regions)
        min_popul = sum(qtys .* pops)
        if min_popul > x * y
            impossible += 1
        elseif div(x, 3) * div(y, 3) >= sum(qtys)
            possible += 1
        else
            push!(q, idx)
            uncertain += 1
        end
    end

    # println("possible: $possible")
    # println("impossible: $impossible")
    # println("uncertain: $uncertain")
    if !iszero(uncertain)
        println("The following is a list of regions where placement is uncertain:")
        println(q)
        @assert false "At least in one region, it is uncertain whether the all presents can be placed"
    end

    possible
end

end #module

using .Day12: d12_p1
export d12_p1
