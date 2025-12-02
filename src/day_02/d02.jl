
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
    #
    # the example ID ranges in the problem statement
    # 13-element Vector{Vector{Int64}}:
    #  [11, 22]
    #  [95, 99]
    #  [100, 115]
    #  [998, 999]
    #  [1000, 1012]
    #  [222220, 222224]
    #  [446443, 446449]
    #  [565653, 565659]
    #  [1698522, 1698528]
    #  [38593856, 38593862]
    #  [824824821, 824824827]
    #  [1188511880, 1188511890]
    #  [2121212118, 2121212124]
    range_lst = Vector{Vector{Int}}()
    for lst in tmp
        nd1, nd2 = ndigits(lst[1]), ndigits(lst[2])
        r1, r2 = lst[1], lst[2]

        while nd1 < nd2
            push!(range_lst, [r1, 10 ^ nd1 - 1])

            r1 = 10 ^ nd1
            nd1 += 1
        end
        push!(range_lst, [r1, r2])
    end

    range_lst
end

function find_invalid_IDs(d::Int, r1::Int, r2::Int)
    result = Vector{Int}()

    nd = ndigits(r1)
    rep_cnt, r = divrem(nd, d)

    r != 0 && return result

    n = div(r1, 10 ^ (nd - d))
    while true
        x, cnt = n, rep_cnt - 1
        while cnt > 0
            x = 10 ^ d * x + n
            cnt -= 1
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
    for lst in data
        r1, r2 = lst[1], lst[2]
        d = div(ndigits(r1), 2)
        append!(result, find_invalid_IDs(d, r1, r2))
    end

    sum(unique(result))
end

function d02_p2(fname::String = "input")
    data = parse_file(fname)

    result = Vector{Int}()
    for lst in data
        r1, r2 = lst[1], lst[2]
        d = div(ndigits(r1), 2)
        while d > 0
            append!(result, find_invalid_IDs(d, r1, r2))
            d -= 1
        end
    end

    sum(unique(result))
end

end #module

using .Day02: d02_p1, d02_p2
export d02_p1, d02_p2
