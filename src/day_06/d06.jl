
module Day06

function parse_file(fname::String)
    data = readlines(joinpath(@__DIR__, fname))

    matrix = stack(collect.(@view data[1:end - 1]), dims = 1)

    sep_indices = findall(col -> all(==(' '), col), eachcol(matrix))
    rngs = zip(vcat(1, sep_indices .+ 1), vcat(sep_indices .- 1, size(matrix, 2)))

    op_lst = map(s -> s == "+" ? (+) : (*), split(data[end]))

    matrix, rngs, op_lst
end

function chs_to_int(chs::AbstractArray{Char})
    acc = 0
    for ch in chs
        !isnumeric(ch) && continue
        acc = acc * 10 + (ch - '0')
    end

    acc
end

function d06(fname::String, fn::Function)
    matrix, rngs, op_lst = parse_file(fname)

    q = Vector{Int}()
    idx = 1
    acc = 0
    for (start, stop) in rngs
        for chs in fn(@view matrix[:, start:stop])
            push!(q, chs_to_int(chs))
        end
        acc += reduce(op_lst[idx], q)
        empty!(q)
        idx += 1
    end

    acc
end

d06_p1(fname::String = "input") = d06(fname, eachrow)
d06_p2(fname::String = "input") = d06(fname, eachcol)

end #module

using .Day06: d06_p1, d06_p2
export d06_p1, d06_p2
