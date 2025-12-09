
module Day09

function parse_file(fname::String)
    map(v -> Tuple(parse.(Int, v)), split.(readlines(joinpath(@__DIR__, fname)), !isnumeric))
end

area(x1::Int, y1::Int, x2::Int, y2::Int) = (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)

function d09_p1(fname::String = "input")
    corner_lst = parse_file(fname)  # red tiles

    max_area = 0
    for i = 1:(length(corner_lst) - 1), j = (i + 1):length(corner_lst)
        x1, y1 = corner_lst[i]
        x2, y2 = corner_lst[j]
        max_area = max(max_area, area(x1, y1, x2, y2))
    end

    max_area
end

function classify_edges(corner_lst::Vector{Tuple{Int, Int}})
    v_edges = Vector{Tuple{Int, Tuple{Int, Int}}}()
    h_edges = Vector{Tuple{Int, Tuple{Int, Int}}}()
    sizehint!(v_edges, div(length(corner_lst), 2))
    sizehint!(h_edges, div(length(corner_lst), 2))

    for i in eachindex(corner_lst)
        x1, y1 = corner_lst[i]
        x2, y2 = corner_lst[mod1(i + 1, length(corner_lst))]

        if x1 == x2
            # vertical edge: (x, (y_start, y_end))
            push!(v_edges, (x1, minmax(y1, y2)))
        elseif y1 == y2
            # horizontal edge: (y, (x_start, x_end))
            push!(h_edges, (y1, minmax(x1, x2)))
        else
            @assert false "invali input data"
        end
    end

    v_edges, h_edges
end

function make_rectangles(corner_lst::Vector{Tuple{Int, Int}})
    rectangles = Vector{Tuple{Tuple{Int, Int}, Tuple{Int, Int}}}()

    for i = 1:(length(corner_lst) - 1), j = (i + 1):length(corner_lst)
        push!(rectangles, (corner_lst[i], corner_lst[j]))
    end
    sort!(rectangles, by = (((x1, y1), (x2, y2)),) -> area(x1, y1, x2, y2), rev = true)

    rectangles
end

function is_valid_rectangle(
    p1::Tuple{Int, Int},
    p2::Tuple{Int, Int},
    corner_set::Set{Tuple{Int, Int}},
    v_edges::Vector{Tuple{Int, Tuple{Int, Int}}},
    h_edges::Vector{Tuple{Int, Tuple{Int, Int}}}
)
    x1, y1 = p1
    x2, y2 = p2

    # check wheter other two corners are red or green tiles
    for (x, y) in ((x1, y2), (x2, y1))
        # is (x, y) a red tile?
        (x, y) in corner_set && continue

        # is (x, y) a green tile?
        cnt = 0
        for (e_x, (e_y1, e_y2)) in v_edges
            if e_x <= x && (e_y1 <= y < e_y2)
                cnt += 1
            end
        end

        iseven(cnt) && return false
    end

    # check whether each edge of the loop doesn't cross the rectangle
    x_start, x_end = minmax(x1, x2)
    y_start, y_end = minmax(y1, y2)

    # vertical edges
    for (e_x, (e_y1, e_y2)) in v_edges
        if x_start < e_x < x_end
            if y_start < e_y2 && e_y1 < y_end
                return false
            end
        end
    end

    # horizontal edges
    for (e_y, (e_x1, e_x2)) in h_edges
        if y_start < e_y < y_end
            if x_start < e_x2 && e_x1 < x_end
                return false
            end
        end
    end

    true
end

function d09_p2(fname::String = "input")
    corner_lst = parse_file(fname)
    corner_set = Set(corner_lst)
    v_edges, h_edges = classify_edges(corner_lst)
    rectangles = make_rectangles(corner_lst)

    for (p1, p2) in rectangles
        if is_valid_rectangle(p1, p2, corner_set, v_edges, h_edges)
            return area(p1..., p2...)
        end
    end

    @assert false "unreachable"
end

end #module

using .Day09: d09_p1, d09_p2
export d09_p1, d09_p2
