
module Day05

function parse_file(fname::String)
    data = split(readchomp(joinpath(@__DIR__, fname)), "\n\n")

    rngs = make_ranges(data[1])
    ingrs = parse.(Int, split(data[2]))

    rngs, ingrs
end

# make a list of fresh ingredient ID range objects. each range doesn't overlap.
#
# please see the comment of day_02/d02.jl:make_ranges() if you need to know this algorithm.
function make_ranges(rng_data::AbstractString)
    event_seq = sort(
        zip(parse.(Int, split(rng_data, !isnumeric)), Iterators.cycle((1, -1))) |> collect,
        lt = (x, y) -> (x[1] < y[1] || (x[1] == y[1] && x[2] > y[2]))
    )

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

    count(id -> any(rng -> id ∈ rng, rngs), ingrs)
end

function d05_p2(fname::String = "input")
    rngs, _ = parse_file(fname)

    sum(length, rngs)
end

end #module

using .Day05: d05_p1, d05_p2
export d05_p1, d05_p2
