
module Day03

function parse_file(fname::String)
    map(lst -> parse.(Int, lst), collect.(readlines(joinpath(@__DIR__, fname))))
end

function find_max_joltage(bank::AbstractVector{Int}, n_batts::Int)
    left = firstindex(bank)
    acc = 0
    for x = reverse(0:n_batts - 1)
        d, idx = findmax(@view bank[left:end - x])
        left += idx
        acc = acc * 10 + d
    end

    acc
end

function d03_p1(fname::String = "input"; n_batts = 2)
    data = parse_file(fname)

    sum(map(bank -> find_max_joltage(bank, n_batts), data))
end

function d03_p2(fname::String = "input"; n_batts = 12)
    data = parse_file(fname)

    sum(map(bank -> find_max_joltage(bank, n_batts), data))
end

end #module

using .Day03: d03_p1, d03_p2
export d03_p1, d03_p2
