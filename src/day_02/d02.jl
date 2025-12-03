
#=
[Memo]
Solved this problem without using string comparison. However, using it
might be slightly inefficient, but it could be a simpler approach.
=#

module Day02

function parse_file(fname::String)
    tmp = sort(
        broadcast(
            lst -> parse.(Int, lst),
            split.(split(chomp(read(joinpath(@__DIR__, fname), String)), ","), "-")
        ),
        by = first
    )

    # Normalization (match the number of digits in the start number and end number)
    #   [11, 22] -> (11, 22)
    #   [95, 115] -> (95, 99), (100, 115)
    #     ..., and so on
    range_lst = Vector{Tuple{Int, Int}}()
    for lst in tmp
        r1, r2 = lst[1], lst[2]
        nd1, nd2 = ndigits(r1), ndigits(r2)

        while nd1 < nd2
            push!(range_lst, (r1, 10 ^ nd1 - 1))

            r1 = 10 ^ nd1
            nd1 += 1
        end
        push!(range_lst, (r1, r2))
    end

    range_lst
end

# Find invalid IDs which length of repeating block is `d` from [r1, r2]
#   241241        999
#   ^^^ d = 3     ^ d = 1
function find_invalid_IDs(r1::Int, r2::Int, d::Int)
    @assert ndigits(r1) == ndigits(r2) "The number of digits in the start number and end number must be the same"

    result = Vector{Int}()

    nd = ndigits(r1)
    2d > nd && return result

    rep_cnt, r = divrem(nd, d)
    r != 0 && return result

    n = div(r1, 10 ^ (nd - d))
    while true
        x = n
        for _ = 1:(rep_cnt - 1)
            x = 10 ^ d * x + n
        end

        n += 1
        x > r2 && break
        x < r1 && continue

        push!(result, x)
    end

    result
end

function d02_p1(fname::String = "input")
    data = filter(lst -> iseven(ndigits(lst[1])), parse_file(fname))

    result = Vector{Int}()
    for (r1, r2) in data
        d = div(ndigits(r1), 2)
        append!(result, find_invalid_IDs(r1, r2, d))
    end

    sum(unique(result))
end

function d02_p2(fname::String = "input")
    data = parse_file(fname)

    result = Vector{Int}()
    for (r1, r2) in data
        foreach(1:div(ndigits(r1), 2)) do d
            append!(result, find_invalid_IDs(r1, r2, d))
        end
    end

    sum(unique(result))
end

end #module

using .Day02: d02_p1, d02_p2
export d02_p1, d02_p2
