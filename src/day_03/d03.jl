
module Day03

function parse_file(fname::String)
    map(lst -> parse.(Int, lst), collect.(readlines(joinpath(@__DIR__, fname))))
end

function find_max_joltage(bank::AbstractVector{Int}, n_batts::Int)
    @assert n_batts <= length(bank) "n_batts must be less than or equal to the total number of batteries"

    left = firstindex(bank)
    acc = 0
    for x = reverse(0:n_batts - 1)
        d, idx = findmax(@view bank[left:end - x])
        left += idx
        acc = acc * 10 + d
    end

    acc
end

function d03(fname::String, n_batts::Int)
    data = parse_file(fname)

    sum(map(bank -> find_max_joltage(bank, n_batts), data))
end

d03_p1(fname::String = "input"; n_batts = 2) = d03(fname, n_batts)
d03_p2(fname::String = "input"; n_batts = 12) = d03(fname, n_batts)

end #module

using .Day03: d03_p1, d03_p2
export d03_p1, d03_p2
