
module Day08

import ..UnionFind: Disjoint, is_same, unite!, groups, group_size

struct Box
    x::Int
    y::Int
    z::Int
end

distance(p1::Box, p2::Box) = (p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2 + (p1.z - p2.z) ^ 2

function parse_file(fname::String)
    map(split.(readlines(joinpath(@__DIR__, fname)), !isnumeric)) do v
        Box(parse.(Int, v)...)
    end
end

function make_conn_lst(boxes::Vector{Box})
    conns = Vector{Tuple{Int, Tuple{Int, Int}}}()
    for i = 1:length(boxes) - 1, j = (i + 1):length(boxes)
        push!(conns, (distance(boxes[i], boxes[j]), (i, j)))
    end
    sort!(conns, lt = (x, y) -> x[1] < y[1])

    conns
end

function d08_p1(fname::String = "input"; cnt = 1_000)
    boxes = parse_file(fname)
    conns = make_conn_lst(boxes)
    dj = Disjoint(size(boxes, 1))

    for (_, (i, j)) in Iterators.take(conns, cnt)
        is_same(dj, i, j) && continue
        unite!(dj, i, j)
    end

    reduce(*, sort(map(length, groups(dj)), rev = true)[1:3])
end

function d08_p2(fname::String = "input")
    boxes = parse_file(fname)
    conns = make_conn_lst(boxes)
    dj = Disjoint(size(boxes, 1))

    res = 0
    for (_, (i, j)) in conns
        is_same(dj, i, j) && continue
        unite!(dj, i, j)

        if group_size(dj, i) == length(boxes)
            res = boxes[i].x * boxes[j].x
            break
        end
    end

    res
end

end #module

using .Day08: d08_p1, d08_p2
export d08_p1, d08_p2
