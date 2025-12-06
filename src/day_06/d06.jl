
module Day06

function parse_file(fname::String)
    data = readlines(joinpath(@__DIR__, fname))

    matrix = stack(collect.(@view data[1:end - 1]), dims = 1)

    sep_indices = findall(col -> all(==(' '), col), eachcol(matrix))
    rng_lst = zip(vcat(1, sep_indices .+ 1), vcat(sep_indices .- 1, size(matrix, 2)))

    op_lst = map(s -> s == "+" ? (+) : (*), split(data[end]))

    matrix, rng_lst, op_lst
end

function d06(fname::String, fn::Function)
    matrix, rng_lst, op_lst = parse_file(fname)

    acc = 0
    for ((start, stop), op) in zip(rng_lst, op_lst)
        acc += reduce(op, parse.(Int, join.(fn(@view matrix[:, start:stop]))))
    end

    acc
end

d06_p1(fname::String = "input") = d06(fname, eachrow)
d06_p2(fname::String = "input") = d06(fname, eachcol)

end #module

using .Day06: d06_p1, d06_p2
export d06_p1, d06_p2
