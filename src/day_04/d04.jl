
module Day04

const CIdx = CartesianIndex
const NBRS = CIdx.([(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)])

function parse_file(fname::String)
    # 0: empty space, 1: roll of paper
    map(ch -> ch == '@' ? 1 : 0, stack(collect.(readlines(joinpath(@__DIR__, fname))), dims = 1))
end

function num_adj_rolls(grid::Matrix{Int}, pos::CIdx{2})
    acc = 0
    for delta in NBRS
        acc += get(grid, pos + delta, 0)
    end

    acc
end

function find_rolls_to_remove(grid::Matrix{Int}, thr::Int)
    q = Vector{CIdx{2}}()

    for pos in CartesianIndices(grid)
        # if the space is empty, skip
        grid[pos] == 0 && continue

        if num_adj_rolls(grid, pos) < thr
            push!(q, pos)
        end
    end

    q
end

function d04_p1(fname::String = "input"; thr = 4)
    grid = parse_file(fname)

    find_rolls_to_remove(grid, thr) |> length
end

function d04_p2(fname::String = "input"; thr = 4)
    grid = parse_file(fname)

    acc = 0
    while true
        (rolls = find_rolls_to_remove(grid, thr)) |> isempty && break
        acc += length(rolls)

        # remove rolls of paper from the grid
        grid[rolls] .= 0
    end

    acc
end

end #module

using .Day04: d04_p1, d04_p2
export d04_p1, d04_p2
