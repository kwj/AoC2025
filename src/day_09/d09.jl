
module Day09

#=
Note that I assumed one more constraint to this problem.
  - Parallel lines forming a loop must not be adjacent to each other

BAD:
.............
.#XXX##XXXX#.
.X...XX....X.
.X.#X##XX#.X.
.X.X.....X.X.
.X.X.....X.X.
.X.X.....X.X.
.X #XXXXX#.X.
.X.........X.
.#XXXXXXXXX#.
.............

1,1
5,1
5,3
3,3
3,7
9,7
9,3
6,3
6,1
11,1
11,9
1,9

GOOD:
.............
.#XXX#.#XXX#.
.X...X.X...X.
.X.#X#.#X#.X.
.X.X.....X.X.
.X.X.....X.X.
.X.X.....X.X.
.X #XXXXX#.X.
.X.........X.
.#XXXXXXXXX#.
.............

1,1
5,1
5,3
3,3
3,7
9,7
9,3
7,3
7,1
11,1
11,9
1,9
=#

const Edge = Tuple{Int, Tuple{Int, Int}}

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
    v_edges = Vector{Edge}()
    h_edges = Vector{Edge}()
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
    sort!(v_edges, by = first)
    sort!(h_edges, by = first)

    v_edges, h_edges
end

# return a candidate list of rectangles in descending order by area
function make_rectangles(corner_lst::Vector{Tuple{Int, Int}})
    rectangles = Vector{Tuple{Tuple{Int, Int}, Tuple{Int, Int}}}()

    for i = 1:(length(corner_lst) - 1), j = (i + 1):length(corner_lst)
        x1, x2 = minmax(corner_lst[i][1], corner_lst[j][1])
        y1, y2 = minmax(corner_lst[i][2], corner_lst[j][2])
        push!(rectangles, ((x1, y1), (x2, y2)))
    end
    sort!(rectangles, by = (((x1, y1), (x2, y2)),) -> area(x1, y1, x2, y2), rev = true)

    rectangles
end

function remove_span(lst::Vector{Tuple{Int, Int}}, a1::Int, a2::Int)
    Iterators.flatmap(lst) do (x1, x2)
        if x1 <= a2 && a1 <= x2
            # overlapped
            if a1 <= x1
                if a2 < x2
                    [(a2 + 1, x2)]
                else
                    Tuple{Int, Int}[]
                end
            else
                if a2 < x2
                    [(x1, a1 - 1), (a2 + 1, x2)]
                else
                    [(x1, a1 - 1)]
                end
            end
        else
            [(x1, x2)]
        end
    end |> collect
end

function is_edge_crossed(k::Int, spans::Vector{Tuple{Int, Int}}, edges::Vector{Edge})
    exclusion = (spans[1][1], spans[end][end])

    tpl, state = iterate(edges)
    for (start, stop) in spans
        while tpl[1] < start
            iterate(edges, state) === nothing && return false
            tpl, state = iterate(edges, state)
        end

        n, (e1, e2) = tpl
        while n <= stop
            (e1 < k < e2 && n ∉ exclusion) && return true

            iterate(edges, state) === nothing && return false
            (n, (e1, e2)), state = iterate(edges, state)
        end
    end

    false
end

function is_inside(edges::Vector{Edge}, x::Int, thr::Int)
    cnt = 0
    for (n, (e1, e2)) in edges
        if n < thr && e1 <= x < e2
            cnt += 1
        end
    end

    isodd(cnt)
end

function check_line(
    k::Int,
    span_start::Int,
    span_stop::Int,
    parallel_edges::Vector{Edge},
    orthogonal_edges::Vector{Edge}
)
    # remove all parallel edges from the line
    spans = [(span_start, span_stop)]
    for (n, (e1, e2)) in parallel_edges
        n != k && continue

        spans = remove_span(spans, e1, e2)
        isempty(spans) && return true
    end

    # if any orthogonal edge intersects with the remaing spans, it's not a valid rectangle
    is_edge_crossed(k, spans, orthogonal_edges) && return false

    # check whether all remaing spans are inside the loop
    for (start, _) in spans
        !is_inside(parallel_edges, start, k) && return false
    end

    return true
end

function is_valid_rectangle(
    p1::Tuple{Int, Int},
    p2::Tuple{Int, Int},
    v_edges::Vector{Edge},
    h_edges::Vector{Edge}
)
    # assume that p1 != p2, x1 <= x2 and y1 <= y2
    #   p1: the top left corner of a rectangle
    #   p2: the bottom right corner of a rectangle
    @assert p1 != p2 "invalid coordinates"
    x1, y1 = p1
    x2, y2 = p2

    if x1 == x2
        # the area (x1, y1) - (x2, y2) is a vertical line
        return check_line(x1, y1, y2, v_edges, h_edges)
    elseif y1 == y2
        # the area (x1, y1) - (x2, y2) is a horizontal line
        return check_line(y1, x1, x2, h_edges, v_edges)
    elseif x1 + 1 == x2
        return all(x -> check_line(x, y1, y2, v_edges, h_edges), (x1, x2))
    elseif y1 + 1 == y2
        return all(y -> check_line(y, x1, x2, h_edges, v_edges), (y1, y2))
    else
        # the area p1(x1, y1) - p2(x2, y2) is a rectangle which lenth of edges is larger than or equal to 3

        # 1)
        # check whether the point (x1 + 1, y1 + 1) is inside the loop by ray casting
        #
        #  p1--> *????
        #        ?* <-- (x1 + 1, y1 + 1)
        #        ?
        !is_inside(v_edges, y1 + 1, x1 + 1) && return false

        # 2)
        # check whether each edge of the loop doesn't exist in the area (x1 + 1, y1 + 1) to
        # (x2 - 1, y2 - 1) to verify that the area is filled by green tiles and inside a loop.
        #
        # a) vertical edges
        for (e_x, (e_y1, e_y2)) in v_edges
            if x1 < e_x < x2
                if y1 < e_y2 && e_y1 < y2
                    return false
                end
            end
        end

        # b) horizontal edges
        for (e_y, (e_x1, e_x2)) in h_edges
            if y1 < e_y < y2
                if x1 < e_x2 && e_x1 < x2
                    return false
                end
            end
        end

        # 3)
        # now, there are two unfixed positions in the rectangle.
        #
        #    OOOO?         ...
        # ...ggggO  or ...ggggO  ,and so on   [#: red tile, X/g: green tile (on the loop/inside the loop)]
        #    ggggO        ggggO               [O: red/green tile, ?: unknow yet]]
        #     ...         OOOO?
        #
        # if it assumes that a unfixed corner position '?' is blank space, neigther red tile nor
        # green tile can't be placed at positions '@'. it becomes that both sides of X are blank
        # spaces, it is contradictory.
        #
        #                   .X@           .X.
        #    OOO#.        OOX#.@        OOX#..  [contradiction]
        # ...gggg# --> ...gggg#X --> ...gggg#X
        #    ggggO        ggggX.        ggggX.
        #     ...          ...           ...
        #
        # in conclusion, a position '?' therefore must be a red or green tile.
        # so the area (x1, y1) to (x2, y2) is a valid rectangle.

        return true
    end
end

function d09_p2(fname::String = "input")
    corner_lst = parse_file(fname)
    v_edges, h_edges = classify_edges(corner_lst)
    rectangles = make_rectangles(corner_lst)

    for (p1, p2) in rectangles
        if is_valid_rectangle(p1, p2, v_edges, h_edges)
            return area(p1..., p2...)
        end
    end

    @assert false "unreachable"
end

end #module

using .Day09: d09_p1, d09_p2
export d09_p1, d09_p2

#=
[Another test case #1]
.............
.........#X#.
.........X.X.
.........X.X.
.........X.X.
.........X.X.
.........X.X.
.........X.X.
.........X.X.
.........X.X.
.........X.X.
.#XXXXXXX#.X.
.X.........X.
.#XXXXXXXXX#.
.............

9,1
11,1
11,13
1,13
1,11
9,11

Part 1: 143
Part 2: 39 ((9,1) - (11,13))


[Another test case #2]
.................
.#XXXXXXXXX#.#X#.
.X.........X.X.X.
.X.........#X#.X.
.X.............X.
.X.............X.
.X.............X.
.X.............X.
.X.............X.
.X.............X.
.X.............X.
.#XXXXXXXXXXXXX#.
.................

1,1
11,1
11,3
13,3
13,1
15,1
15,11
1,11

Part 1: 165
Part 2: 121 ((11,1) - (1,11))


[Another test case #3]
..............
.#XXX#.#XXXX#.
.X...X.X....X.
.X.#X#.#X#..X.
.X.X.....X..X.
.X.X.....X..X.
.X.X.....X..X.
.X #XXXXX#..X.
.X..........X.
.#XXXXXXXXXX#.
..............

1,1
5,1
5,3
3,3
3,7
9,7
9,3
7,3
7,1
12,1
12,9
1,9

Part 1: 108
Part 2: 30 ((3,7) - (12,9))


[Another test case #4]
.......................
...#X#...........#X#...
...X.X...........X.X...
.#X#.#XXXXXXXXXXX#.X...
.X.................#X#.
.#XXXXXXXXXXXXXX#....X.
................X....X.
................#XXXX#.
.......................

1,3
3,3
3,1
5,1
5,3
17,3
17,1
19,1
19,4
21,4
21,7
16,7
16,5
1,5

Part 1: 133
Part 2: 51 ((17,3) - (1,5))


[Another test case #5]
.....................
.#X#.#X#.#X#.........
.X.X.X.X.X.X.........
.X #X#.#X#.X.........
.X.........#XXXXXXX#.
.#XXXXXXX#.........X.
.........X.#X#.#X#.X.
.........X.X.X.X.X.X.
.........#X#.#X#.#X#.
.....................

1,1
3,1
3,3
5,3
5,1
7,1
7,3
9,3
9,1
11,1
11,4
19,4
19,8
17,8
17,6
15,6
15,8
13,8
13,6
11,6
11,8
9,8
9,5
1,5

Part 1: 152
Part 2: 38 ((1,5) - (19,4))


[Another test case #6]
..........................
.#X#.#XXXXXX#..#X#........
.X.X.X......X..X.X........
.X #X#......#XX#.X........
.X.....#XX#......#XX#.#X#.
.#XX#  X..X.#X#.....X.X.X.
....X..X..#.X.X.#X#.#X#.X.
....#XX#..#X#.X.X.X.....X.
............. #X#.#XXXXX#.
..........................

1,1
3,1
3,3
5,3
5,1
12,1
12,3
15,3
15,1
17,1
17,4
20,4
20,6
22,6
22,4
24,4
24,8
18,8
18,6
16,6
16,8
14,8
14,5
12,5
12,7
10,7
10,4
7,4
7,7
4,7
4,5
1,5

Part 1: 192
Part 2: 30 ((3,3) - (17,4))


[Another test case #7]
..........................
.#X#.#XXXXXX#..#X#........
.X.X.X......X..X.X........
.X #X#......#XX#.#XX#.....
.X.....#XX#.........X.#X#.
.#XX#  X..X.#X#.....X.X.X.
....X..X..#.X.X.#X#.#X#.X.
....#XX#..#X#.X.X.X.....X.
............. #X#.#XXXXX#.
..........................

1,1
3,1
3,3
5,3
5,1
12,1
12,3
15,3
15,1
17,1
17,3
20,3
20,6
22,6
22,4
24,4
24,8
18,8
18,6
16,6
16,8
14,8
14,5
12,5
12,7
10,7
10,4
7,4
7,7
4,7
4,5
1,5

Part 1: 192
Part 2: 28 ((7,4) - (20,3))


[Another test case #8]
..........................
.#X#.#XXXXXX#..#X#........
.X.X.X......X..X.X........
.X #X#......#XX#.#XX#.....
.X..................X.#X#.
.#XX#  #XX#.#X#.....X.X.X.
....X..X..#.X.X.#X#.#X#.X.
....#XX#..#X#.X.X.X.....X.
............. #X#.#XXXXX#.
..........................

1,1
3,1
3,3
5,3
5,1
12,1
12,3
15,3
15,1
17,1
17,3
20,3
20,6
22,6
22,4
24,4
24,8
18,8
18,6
16,6
16,8
14,8
14,5
12,5
12,7
10,7
10,5
7,5
7,7
4,7
4,5
1,5

Part 1: 192
Part 2: 60 ((1,5) - (20,3))


[Another test case #9]
..........................
.#X#.#XXXXXX#..#X#........
.X.X.X......X..X.X........
.X #X#......#XX#.X........
.X...............#XX#.#X#.
.#XX#  #XX#.#X#.....X.X.X.
....X..X..#.X.X.#X#.#X#.X.
....#XX#..#X#.X.X.X.....X.
............. #X#.#XXXXX#.
..........................

1,1
3,1
3,3
5,3
5,1
12,1
12,3
15,3
15,1
17,1
17,4
20,4
20,6
22,6
22,4
24,4
24,8
18,8
18,6
16,6
16,8
14,8
14,5
12,5
12,7
10,7
10,5
7,5
7,7
4,7
4,5
1,5

Part 1: 192
Part 2: 45 ((1,5) - (15,3))
=#
