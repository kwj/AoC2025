
module Day05

function parse_file(fname::String)
    data = split(readchomp(joinpath(@__DIR__, fname)), "\n\n")

    rngs = make_ranges(data[1])
    ingrs = parse.(Int, split(data[2]))

    rngs, ingrs
end

# make a list of fresh ingredient ID range objects. each range doesn't overlap.
function make_ranges(rng_data::AbstractString)
    # example: event_seq
    #   "1-3\n5-7\n10-15\n7-13"
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
    #   --> [1:3, 5:15]
    rngs = Vector{UnitRange{Int}}()
    start = 0
    counter = 0
    merging = false
    for (n, c) in event_seq
        counter += c
        if merging == false
            start = n
            merging = true
        elseif iszero(counter)
            push!(rngs, range(start, n))
            merging = false
        end
    end

    rngs
end

function d05_p1(fname::String = "input")
    rngs, ingrs = parse_file(fname)

    count(ingrs) do id
        any(rng -> id ∈ rng, rngs)
    end
end

function d05_p2(fname::String = "input")
    rngs, _ = parse_file(fname)

    sum(length, rngs)
end

end #module

using .Day05: d05_p1, d05_p2
export d05_p1, d05_p2
