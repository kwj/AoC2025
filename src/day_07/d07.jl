
module Day07

# column-oriented version
# all tachyon beams move from left to right in this solution

function parse_file(fname::String)
    stack(collect.(readlines(joinpath(@__DIR__, fname))))
end

function d07(fname::String)
    grid = parse_file(fname)

    n_split = 0
    dp_tbl = zeros(Int, size(grid))
    dp_tbl[findfirst(==('S'), grid)] = 1

    for c = 2:last(axes(grid, 2))
        beam_row_indices = findall(!iszero, @view dp_tbl[:, c - 1])

        for r in beam_row_indices
            if grid[r, c] == '^'
                dp_tbl[r - 1, c] += dp_tbl[r, c - 1]
                dp_tbl[r + 1, c] += dp_tbl[r, c - 1]
                n_split += 1
            else
                dp_tbl[r, c] += dp_tbl[r, c - 1]
            end
        end
    end

    n_split, sum(@view dp_tbl[:, end])
end

d07_p1(fname::String = "input") = d07(fname)[1]
d07_p2(fname::String = "input") = d07(fname)[2]

end #module

using .Day07: d07_p1, d07_p2
export d07_p1, d07_p2
