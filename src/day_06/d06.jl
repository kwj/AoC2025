
module Day06

function parse_file(fname::String)
    data = readlines(joinpath(@__DIR__, fname))

    matrix = stack(collect.(@view data[1:end - 1]), dims = 1)

    sep_indices = findall(col -> all(==(' '), col), eachcol(matrix))
    spans = map(
        ((start, stop),) -> start:stop,
        zip(vcat(1, sep_indices .+ 1), vcat(sep_indices .- 1, size(matrix, 2)))
    )

    ops = map(s -> s == "+" ? (+) : (*), split(data[end]))

    matrix, spans, ops
end

function d06(fname::String, fn::Function)
    matrix, spans, ops = parse_file(fname)

    sum(zip(spans, ops)) do (span, op)
        reduce(op, parse.(Int, join.(fn(@view matrix[:, span]))))
    end
end

d06_p1(fname::String = "input") = d06(fname, eachrow)
d06_p2(fname::String = "input") = d06(fname, eachcol)

end #module

using .Day06: d06_p1, d06_p2
export d06_p1, d06_p2
