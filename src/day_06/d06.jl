
module Day06

function parse_file(fname::String)
    data = readlines(joinpath(@__DIR__, fname))

    matrix = stack(collect.(@view data[1:end - 1]), dims = 1)
    op_lst = map(s -> s == "+" ? (+) : (*), split(data[end]))

    matrix, op_lst
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
    matrix, op_lst = parse_file(fname)
    sep_indices = findall(col -> all(==(' '), col), eachcol(matrix))
    rngs = zip(vcat(1, map(x -> x + 1, sep_indices)), vcat(map(x -> x - 1, sep_indices), size(matrix, 2)))

    q = Vector{Int}()
    idx = 1
    acc = 0
    for (start, stop) in rngs
        for chs in eachrow(fn(@view matrix[:, start:stop]))
            push!(q, chs_to_int(chs))
        end
        acc += reduce(op_lst[idx], q)
        empty!(q)
        idx += 1
    end

    acc

end

d06_p1(fname::String = "input") = d06(fname, identity)
d06_p2(fname::String = "input") = d06(fname, transpose)

end #module

using .Day06: d06_p1, d06_p2
export d06_p1, d06_p2
