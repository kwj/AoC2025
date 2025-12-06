
module Day06

function parse_file(fname::String)
    data = readlines(joinpath(@__DIR__, fname))

    matrix = stack(collect.(@view data[1:end - 1]), dims = 1)
    op_lst = map(s -> s == "+" ? (+) : (*), split(data[end]))

    matrix, op_lst
end

function d06_p1(fname::String = "input")
    char_mt, op_lst = parse_file(fname)
    mt = parse.(Int, stack(split.(reduce.(*, eachrow(char_mt))), dims = 1))

    acc = 0
    for (idx, col) in pairs(eachcol(mt))
        acc += reduce(op_lst[idx], col)
    end

    acc
end

function d06_p2(fname::String = "input")
    char_mt, op_lst = parse_file(fname)
    sep_str = " " ^ size(char_mt, 1)

    vs = reduce.(*, eachcol(char_mt))
    push!(vs, sep_str)  # add a record terminator for the last record

    q = Vector{Int}()
    idx = 1
    acc = 0
    for s in vs
        if s != sep_str
            push!(q, parse(Int, s))
        else
            acc += reduce(op_lst[idx], q)
            empty!(q)
            idx += 1
        end
    end

    acc
end

end #module

using .Day06: d06_p1, d06_p2
export d06_p1, d06_p2
