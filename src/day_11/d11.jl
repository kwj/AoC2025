
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

function d11_p1(fname::String = "input")
    function aux(d::String, memo::Dict{String, Int}, devs::Dict{String, Vector{String}})
        get!(memo, d) do
            d == "out" ? 1 : sum(next_d -> aux(next_d, memo, devs), devs[d])
        end
    end

    dev_info = parse_file(fname)
    memo = Dict{String, Int}()

    aux("you", memo, dev_info)
end

struct State
    dev_name::String
    dac::Bool
    fft::Bool
end

State(x::State; dev_name = x.dev_name, dac = x.dac, fft = x.fft) = State(dev_name, dac, fft)

function d11_p2(fname::String = "input")
    function aux(st::State, memo::Dict{State, Int}, devs::Dict{String, Vector{String}})
        get!(memo, st) do
            if st.dev_name == "out"
                (st.dac && st.fft) ? 1 : 0
            else
                if st.dev_name == "dac"
                    st = State(st, dac = true)
                elseif st.dev_name == "fft"
                    st = State(st, fft = true)
                end

                sum(devs[st.dev_name]) do next_d
                    aux(State(st, dev_name = next_d), memo, devs)
                end
            end
        end
    end

    dev_info = parse_file(fname)
    memo = Dict{State, Int}()

    aux(State("svr", false, false), memo, dev_info)
end

end #module

using .Day11: d11_p1, d11_p2
export d11_p1, d11_p2
