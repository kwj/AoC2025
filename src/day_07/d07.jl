
module Day07

function parse_file(fname::String)
    stack(collect.(readlines(joinpath(@__DIR__, fname))), dims = 1)
end

function d07(fname::String)
    grid = parse_file(fname)

    n_split = 0
    dp_tbl = zeros(Int, size(grid))
    dp_tbl[findfirst(==('S'), grid)] = 1

    for r = 1:(size(grid, 1) - 1)
        beam_columns = findall(!iszero, @view dp_tbl[r, :])

        for c in beam_columns
            if grid[r + 1, c] == '^'
                dp_tbl[r + 1, c - 1] += dp_tbl[r, c]
                dp_tbl[r + 1, c + 1] += dp_tbl[r, c]
                n_split += 1
            else
                dp_tbl[r + 1, c] += dp_tbl[r, c]
            end
        end
    end

    n_split, sum(@view dp_tbl[end, :])
end

d07_p1(fname::String = "input") = d07(fname)[1]
d07_p2(fname::String = "input") = d07(fname)[2]

end #module

using .Day07: d07_p1, d07_p2
export d07_p1, d07_p2
