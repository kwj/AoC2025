
module Day07

function parse_file(fname::String)
    collect.(readlines(joinpath(@__DIR__, fname)))
end

function d07(fname::String)
    header, rows... = parse_file(fname)
    @assert all(line -> length(line) == length(header), rows) "invalid input data"

    cur_beams = zeros(Int, size(header))
    cur_beams[findfirst(==('S'), header)] = 1
    next_beams = zeros(Int, size(header))
    n_split = 0

    for line in rows
        fill!(next_beams, 0)
        for idx in findall(!iszero, cur_beams)
            if line[idx] == '^'
                next_beams[idx - 1] += cur_beams[idx]
                next_beams[idx + 1] += cur_beams[idx]
                n_split += 1
            else
                next_beams[idx] += cur_beams[idx]
            end
        end
        cur_beams, next_beams = next_beams, cur_beams
    end

    n_split, sum(cur_beams)
end

d07_p1(fname::String = "input") = d07(fname)[1]
d07_p2(fname::String = "input") = d07(fname)[2]

end #module

using .Day07: d07_p1, d07_p2
export d07_p1, d07_p2
