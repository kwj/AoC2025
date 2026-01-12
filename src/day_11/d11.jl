
module Day11

function parse_file(fname::String)
    dev_info = Dict{String, Vector{String}}()

    #for line in readlines(fname)
    for line in readlines(joinpath(@__DIR__, fname))
        k, rest... = split(line)
        dev_info[k[1:end - 1]] = rest
    end

    dev_info
end

# part one
function count_paths(devs::Dict{String, Vector{String}}, d::String, memo = Dict{String, Int}())
    get!(memo, d) do
        d == "out" ? 1 : sum(next_d -> count_paths(devs, next_d, memo), devs[d])
    end
end

# part two
struct State
    dev_name::String
    dac::Bool
    fft::Bool
end

State(dev_name::String) = State(dev_name, false, false)
State(x::State; dev_name = x.dev_name, dac = x.dac, fft = x.fft) = State(dev_name, dac, fft)

function count_paths(devs::Dict{String, Vector{String}}, st::State, memo = Dict{State, Int}())
    get!(memo, st) do
        if st.dev_name == "out"
            (st.dac && st.fft) ? 1 : 0
        else
            if st.dev_name == "dac"
                @assert st.dac == false "a cycle is found (dac)"
                st = State(st, dac = true)
            elseif st.dev_name == "fft"
                @assert st.fft == false "a cycle is found (fft)"
                st = State(st, fft = true)
            end

            sum(devs[st.dev_name]) do next_d
                count_paths(devs, State(st, dev_name = next_d), memo)
            end
        end
    end
end

d11_p1(fname::String = "input") = count_paths(parse_file(fname), "you")
d11_p2(fname::String = "input") = count_paths(parse_file(fname), State("svr"))

end #module

using .Day11: d11_p1, d11_p2
export d11_p1, d11_p2
