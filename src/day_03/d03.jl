
module Day03

function parse_file(fname::String)
    map(lst -> parse.(Int, lst), split.(readlines(joinpath(@__DIR__, fname)), ""))
end

function find_max_joltage(bank::AbstractVector{Int}, rest::Int, left::Int, acc::Int)
    iszero(rest) && return acc

    d, idx = findmax(@view bank[left:end - rest + 1])
    find_max_joltage(bank, rest - 1, left + idx, acc * 10 + d)
end

function d03_p1(fname::String = "input"; n_batts = 2)
    data = parse_file(fname)

    sum(map(bank -> find_max_joltage(bank, n_batts, 1, 0), data))
end

function d03_p2(fname::String = "input"; n_batts = 12)
    data = parse_file(fname)

    sum(map(bank -> find_max_joltage(bank, n_batts, 1, 0), data))
end

end #module

using .Day03: d03_p1, d03_p2
export d03_p1, d03_p2
