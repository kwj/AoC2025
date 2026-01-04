
module Day02

function parse_file(fname::String)
    rng_tpls = make_ranges(readchomp(joinpath(@__DIR__, fname)))

    # Normalization (match the number of digits in the start number and end number)
    #   (11, 22) -> (11, 22)
    #   (95, 115) -> (95, 99), (100, 115)
    #     ..., and so on
    result = Vector{Tuple{Int, Int}}()
    for (r1, r2) in rng_tpls
        nd1, nd2 = ndigits(r1), ndigits(r2)

        while nd1 < nd2
            push!(result, (r1, 10 ^ nd1 - 1))

            r1 = 10 ^ nd1
            nd1 += 1
        end
        push!(result, (r1, r2))
    end

    result
end

# make a list of range tuples. each range doesn't overlap.
function make_ranges(rng_data::AbstractString)
    # example: event_seq
    #   "1-3,5-7,10-15,7-13"
    #   --> [(1, 1), (3, -1), (5, 1), (7, 1), (7, -1), (10, 1), (13, -1), (15, -1)]
    #
    # Note (*1):
    # When the start of a range and the end of a range occur at the same timing,
    # the start takes precedence over sorting. In the above example,
    # (7, 1) takes precedence over (7, -1).
    event_seq = sort(
        zip(parse.(Int, split(rng_data, !isnumeric)), Iterators.cycle((1, -1))) |> collect,
        lt = (x, y) -> (x[1] < y[1] || (x[1] == y[1] && x[2] > y[2]))  # (*1)
    )

    # example: rngs
    #   [(1, 1), (3, -1), (5, 1), (7, 1), (7, -1), (10, 1), (13, -1), (15, -1)]
    #   --> [(1, 3), (5, 15)]
    rngs = Vector{Tuple{Int, Int}}()
    start = 0
    counter = 0
    merging = false
    for (n, c) in event_seq
        counter += c
        if merging == false
            # This method can't concatenate adjacent ranges.
            # For example, it doesn't concatenate (1,5) and (6,10) to (1,10)
            # If such functionality is required, add it here.
            start = n
            merging = true
        elseif iszero(counter)
            push!(rngs, (start, n))
            merging = false
        end
    end

    rngs
end

# Find invalid IDs whose repeating block are d digits from [r1, r2]
#   241241        999
#   ^^^ d = 3     ^ d = 1
function find_invalid_IDs(r1::Int, r2::Int, d::Int)
    @assert ndigits(r1) == ndigits(r2) "The number of digits in the start number and end number must be the same"
    @assert d > 0 "`d` must be positive"

    result = Vector{Int}()

    nd = ndigits(r1)
    rep_cnt, r = divrem(nd, d)
    (r != 0 || rep_cnt < 2) && return result

    # n: repeating block number (the initial value is the first `d` digits of r1)
    n = div(r1, 10 ^ (nd - d))
    while true
        # create an invalid ID
        x = n
        for _ = 1:(rep_cnt - 1)
            x = 10 ^ d * x + n
        end

        n += 1

        # boundary check
        x > r2 && break
        x < r1 && continue

        push!(result, x)
    end

    result
end

function d02_p1(fname::String = "input")
    rng_tpls = parse_file(fname)

    sum(rng_tpls) do (r1, r2)
        if (d2 = ndigits(r1); isodd(d2))
            0
        else
            sum(find_invalid_IDs(r1, r2, div(d2, 2)))
        end
    end
end

function d02_p2(fname::String = "input")
    rng_tpls = parse_file(fname)

    q = Vector{Int}()
    sum(rng_tpls) do (r1, r2)
        empty!(q)
        foreach(1:div(ndigits(r1), 2)) do d
            append!(q, find_invalid_IDs(r1, r2, d))
        end
        sum(unique(q))
    end
end

end #module

using .Day02: d02_p1, d02_p2
export d02_p1, d02_p2
