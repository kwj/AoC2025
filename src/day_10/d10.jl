
module Day10

import ..Simplex: simplex_method

function parse_file(fname::String)
    lights = Vector{Vector{Int}}()
    buttons_lst = Vector{Vector{Vector{Int}}}()
    joltages = Vector{Vector{Int}}()

    #for line in split.(readlines(fname), isspace)
    for line in split.(readlines(joinpath(@__DIR__, fname)), isspace)
        push!(lights, map(ch -> ch == '#' ? 1 : 0, collect(line[1][begin + 1:end - 1])))
        push!(joltages, (map(s -> parse(Int, s), split(line[end], !isnumeric, keepempty = false))))

        idxes = map.(
            x -> parse(Int, x) + 1,
            split.(line[begin + 1:end - 1], !isnumeric, keepempty = false)
        )
        tmp = [zeros(Int, length(lights[end])) for _ in 1:length(idxes)]
        foreach(pairs(tmp)) do (i, bt)
            bt[idxes[i]] .= 1
        end
        push!(buttons_lst, tmp)
    end

    lights, buttons_lst, joltages
end

undigits(lst::AbstractVector{T}; base::Integer = 10) where {T<:Integer} = undigits(T, lst; base = base)

function undigits(T::Type{<:Integer}, lst::AbstractVector{U}; base::Integer = 10) where {U<:Integer}
    foldr((x, acc) -> acc * base + x, lst; init = zero(T))
end

# a naive brute-force search
function min_steps_lighting(light::Vector{Int}, buttons::Vector{Vector{Int}})
    target = undigits(light, base = 2)
    start = 0
    seen = Set{Int}(start)
    btns = map(lst -> undigits(lst, base = 2), buttons)

    state = [start]
    next_state = Vector{Int}()

    steps = 0
    while steps <= length(btns)
        steps += 1
        empty!(next_state)

        for x1 in state, x2 in btns
            v = xor(x1, x2)
            if v ∉ seen
                push!(seen, v)
                push!(next_state, v)
            end
        end

        target ∈ seen && return steps

        state, next_state = next_state, state
    end

    @assert false "unreachable"
end

function d10_p1(fname::String = "input")
    lights, buttons_lst, _ = parse_file(fname)

    sum(zip(lights, buttons_lst)) do (light, buttons)
        min_steps_lighting(light, buttons)
    end
end

function d10_p2(fname::String = "input")
    _, buttons_lst, joltages = parse_file(fname)

    acc = 0
    for (btns, b) in zip(buttons_lst, joltages)
        A = hcat(btns...)
        c = fill(1, size(A, 2))
        relations = fill(:eq, size(A, 1))
        ints_flag = fill(true, size(A, 2))

        xs = simplex_method(A, b, c, :minimize, relations, ints_flag)

        @assert !isnothing(xs) "error"
        acc += sum(round.(Int, xs))
    end

    acc
end

end #module

using .Day10: d10_p1, d10_p2
export d10_p1, d10_p2


#=
This version uses the simplex algorithm with branch-and-bound for mixed integer linear programming.
Compared to a recursive algorithm, it requires a long compile time during the first execution.

julia> @time d10_p2("input")
 20.548735 seconds (8.31 M allocations: 452.729 MiB, 2.19% gc time, 98.00% compilation time)
*****

julia> @time d10_p2("input")
  0.308357 seconds (1.23 M allocations: 102.622 MiB, 18.94% gc time)
*****


[recursive algorithm]
julia> @time d10_p2("input")
  1.671517 seconds (8.35 M allocations: 338.792 MiB, 28.28% gc time)

function min_steps_charging(
    target::Vector{Int},
    amounts::Dict{String, Vector{Int}},
    patterns::Dict{String, Vector{Vector{Int}}},
    memo = Dict{Vector{Int}, Int}()
)
    any(<(0), target) && return typemax(Int16)

    get!(memo, target) do
        all(iszero, target) && return 0

        acc = typemax(Int16)
        lights = join(i % 2 for i in target)
        if haskey(patterns, lights)
            for presses in patterns[lights]
                next_target = [div(x - y, 2) for (x, y) in zip(target, amounts[join(presses)])]
                acc = min(acc, sum(presses) + min_steps_charging(next_target, amounts, patterns, memo) * 2)
            end
        end

        acc
    end
end

function d10_p2(fname::String = "input")
    _, buttons_lst, joltages = parse_file(fname)

    max_buttons = maximum(length, buttons_lst)
    press_tbl = zeros(Int, max_buttons, 2 ^ max_buttons)
    for i = 0:(2 ^ max_buttons - 1)
        press_tbl[:, i + 1] = digits(i, base = 2, pad = max_buttons)
    end

    result = 0
    for (buttons, joltage) in zip(buttons_lst, joltages)
        n_buttons = length(buttons)

        amounts = Dict{String, Vector{Int}}()
        patterns = Dict{String, Vector{Vector{Int}}}()

        for presses in eachcol(@view press_tbl[1:n_buttons, 1:(2 ^ n_buttons)])
            jolts_level = zeros(Int, length(joltage))
            for (idx, v) in pairs(presses)
                if !iszero(v)
                    jolts_level += buttons[idx]
                end
            end

            amounts[join(presses)] = jolts_level

            lights = join(i % 2 for i in jolts_level)
            push!(get!(patterns, lights, []), presses)
        end

        result += min_steps_charging(joltage, amounts, patterns)
    end

    result
end

=#
