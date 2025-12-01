
module Day01

function parse_file(fname::String)
    parse.(Int, replace.(readlines(joinpath(@__DIR__, fname)), "R" => "", "L" => "-"))
end

function d01_p1(fname::String = "input")
    data = parse_file(fname)

    count(iszero, accumulate((acc, x) -> mod(acc + x, 100), data, init=50))
end

function d01_p2(fname::String = "input")
    data = parse_file(fname)

    acc = 0
    pos = 50  # This value is always non-negative. pos ∈ [0, 99]
    for x in data
        next_pos = pos + x

        if iszero(next_pos)
            acc += 1
        elseif next_pos > 0
            acc += div(next_pos, 100)
        else
            acc += div(abs(next_pos), 100) + (iszero(pos) ? 0 : 1)
        end

        pos = mod(next_pos, 100)
    end

    acc
end

end #module

using .Day01: d01_p1, d01_p2
export d01_p1, d01_p2
