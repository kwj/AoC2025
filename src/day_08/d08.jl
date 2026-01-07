
module Day08

import ..UnionFind: DisjointSet, unite!, groups, group_size

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

    # return sorted `conns`
    # to reduce memory usage, use the in-place QuickSort algorithm
    sort!(conns, alg = QuickSort, by = first)
end

# part one
function loop(boxes::Vector{Box}, cnt::Int)
    conns = make_conn_lst(boxes)
    djs = DisjointSet(length(boxes))

    for (_, (i, j)) in Iterators.take(conns, cnt)
        unite!(djs, i, j)
    end

    reduce(*, @view sort(map(length, groups(djs)), rev = true)[1:3])
end

# part two
function loop(boxes::Vector{Box})
    conns = make_conn_lst(boxes)
    djs = DisjointSet(length(boxes))

    for (_, (i, j)) in conns
        unite!(djs, i, j)

        if group_size(djs, 1) == length(boxes)
            return boxes[i].x * boxes[j].x
        end
    end

    @assert false "unreachable"
end

d08_p1(fname::String = "input"; thr = 1_000) = loop(parse_file(fname), thr)
d08_p2(fname::String = "input") = loop(parse_file(fname))

end #module

using .Day08: d08_p1, d08_p2
export d08_p1, d08_p2
