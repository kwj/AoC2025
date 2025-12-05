
module Day05

function parse_file(fname::String)
    data = split(readchomp(joinpath(@__DIR__, fname)), "\n\n")

    rngs = make_ranges(data[1])
    ingrs = parse.(Int, split(data[2]))

    rngs, ingrs
end

function make_ranges(rng_data::AbstractString)
    rngs = Vector{UnitRange{Int}}()

    # merge overlapping areas within the fresh ingredient ID ranges
    start = 0
    counter = 0
    merging = false
    for (n, c) in sort(zip(parse.(Int, split(rng_data, !isnumeric)), Iterators.cycle((1, -1))) |> collect, by = first)
        counter += c
        if merging == false
            if !isempty(rngs) && last(rngs[end]) == n
                # if the start value of range is equal to the end value of the immediately preceding range object,
                # set the new start value to that object's start value and discard the object
                start = first(rngs[end])
                pop!(rngs)
            else
                start = n
            end
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
