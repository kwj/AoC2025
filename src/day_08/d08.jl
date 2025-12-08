
module Day08

import ..UnionFind: Disjoint, is_same, unite!, groups, group_size

struct Box
    x::Int
    y::Int
    z::Int
end

distance(b1::Box, b2::Box) = (b1.x - b2.x) ^ 2 + (b1.y - b2.y) ^ 2 + (b1.z - b2.z) ^ 2

function parse_file(fname::String)
    map(split.(readlines(joinpath(@__DIR__, fname)), !isnumeric)) do v
        Box(parse.(Int, v)...)
    end
end

# make a connection list sorted in ascending order by the distance between each box
function make_conn_lst(boxes::Vector{Box})
    conns = Vector{Tuple{Int, Tuple{Int, Int}}}()
    sizehint!(conns, div(length(boxes) * (length(boxes) - 1), 2))

    for i = 1:length(boxes) - 1, j = (i + 1):length(boxes)
        push!(conns, (distance(boxes[i], boxes[j]), (i, j)))
    end
    # select the in-place algorithm quick sort to reduce memory usage
    sort!(conns, alg = QuickSort, by = first)

    conns
end

function d08(fname::String, thr)
    boxes = parse_file(fname)
    conns = make_conn_lst(boxes)
    dj = Disjoint(size(boxes, 1))

    p1, p2 = 0, 0
    for (cnt, (_, (i, j))) in pairs(conns)
        unite!(dj, i, j)

        if cnt == thr
            p1 = reduce(*, sort(map(length, groups(dj)), rev = true)[1:3])
            break
        end

        if group_size(dj, i) == length(boxes)
            p2 = boxes[i].x * boxes[j].x
            break
        end
    end

    p1, p2
end

d08_p1(fname::String = "input"; thr = 1_000) = d08(fname, thr)[1]
d08_p2(fname::String = "input"; thr = 0) = d08(fname, thr)[2]

end #module

using .Day08: d08_p1, d08_p2
export d08_p1, d08_p2
