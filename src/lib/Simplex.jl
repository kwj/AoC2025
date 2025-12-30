
module Simplex

const EPS = 1.0e-9

# Mixed-Integer Linear Programming (MILP) using simplex method and branch-and-bound
function simplex_method(A, b, c, goal::Symbol, relations::AbstractVector{Symbol}, int_flags::AbstractVector{Bool})::Union{Nothing, Vector{Float64}}
    @assert length(int_flags) == size(A, 2) "the size of the coefficient matrix doesn't match the length of the integer constraint vector"

    function find_non_int_val(xs::Vector{Float64}, int_flags)::Union{Nothing, Tuple{Int, Float64}}
        for (idx, flag) in pairs(int_flags)
            flag == false && continue
            isapprox(xs[idx], round(xs[idx], RoundNearest), atol = EPS) && continue

            return (idx, xs[idx])
        end

        return nothing
    end

    A′ = map(Float64, A)
    b′ = map(Float64, b)
    c′ = map(Float64, c)

    # branch-and-bound
    thr = (goal == :maximize) ? -Inf : Inf
    result::Union{Nothing, Vector{Float64}} = nothing
    q = Tuple{Matrix{Float64}, Vector{Float64}, typeof(relations)}[]
    push!(q, (A′, b′, relations))

    while !isempty(q)
        A′, b′, relations′ = pop!(q)
        xs = simplex_method(A′, b′, c′, goal, relations′)
        isnothing(xs) && continue

        val = sum(((x, y),) -> x * y, zip(c′, xs))
        (goal == :maximize ? val < thr : val > thr) && continue

        if (tpl = find_non_int_val(xs, int_flags); isnothing(tpl))
            thr = val
            result = xs
        else
            i, xᵢ = tpl

            coeff = zeros(Float64, size(A, 2))
            coeff[i] = 1.0

            low = round(xᵢ, RoundDown)
            push!(q, (vcat(A′, transpose(coeff)), vcat(b′, low), vcat(relations′, :le)))

            high = round(xᵢ, RoundUp)
            push!(q, (vcat(A′, transpose(coeff)), vcat(b′, high), vcat(relations′, :ge)))
        end
    end

    if !isnothing(result)
        foreach(pairs(int_flags)) do (idx, flag)
            if flag == true
                result[idx] = round(result[idx])
            end
        end
    end

    result
end

# Linear Programming (LP) using simplex method
function simplex_method(A, b, c, goal::Symbol, relations::AbstractVector{Symbol})::Union{Nothing, Vector{Float64}}
    tbl, Z, basic_vars, artificial_rows, artificial_cols  = prepare_tableau(A, b, c, goal, relations)

    # if even one artificial variable exists, an obvious initial basic feasible
    # solution (BFS) is unknown. so we must first find an initial BFS.
    # (two-phase simplex method)
    if !isempty(artificial_rows)
        z = zeros(Float64, length(Z))
        z[artificial_cols] .= 1.0

        for row in artificial_rows
            z .-= @view tbl[row, :]
        end

        standard_simplex!(tbl, basic_vars, z)

        # if there is no solution, return nothing
        !isapprox(z[end], 0.0, atol = EPS) && return nothing

        # if artificial variables exist among the basic variables, remove them from the basic variables if possible
        for r_idx in findall(in(artificial_cols), basic_vars)
            c_idx = findfirst(x -> !isapprox(x, 0.0, atol = EPS), @view tbl[r_idx, :])
            isnothing(c_idx) && continue

            tbl[r_idx, :] ./= tbl[r_idx, c_idx]

            factor = z[c_idx] / tbl[r_idx, c_idx]
            z .-= factor .* @view tbl[r_idx, :]
            for r in axes(tbl, 1)
                r == r_idx && continue
                factor = tbl[r, c_idx] / tbl[r_idx, c_idx]
                tbl[r, :] .-= factor * @view tbl[r_idx, :]
            end

            basic_vars[r_idx] = c_idx
        end

        deleteat!(Z, artificial_cols)
        tbl = tbl[:, setdiff(axes(tbl, 2), artificial_cols)]

        for row in findall(<=(size(A, 2)), basic_vars)
            x = basic_vars[row]
            factor = Z[x] / tbl[row, x]
            Z .-= factor .* @view tbl[row, :]
        end
    end

    standard_simplex!(tbl, basic_vars, Z)

    result = zeros(Float64, size(A, 2))
    for (idx, x) in pairs(basic_vars)
        x > size(A, 2) && continue
        result[x] = tbl[idx, end]
    end

    result
end

function standard_simplex!(tbl, b_vars, z)
    while ((x, c_idx) = findmin(@view z[begin:end - 1]); x < -EPS)
        (_, r_idx) = findmin(i -> tbl[i, c_idx] > EPS ? abs(tbl[i, end] / tbl[i, c_idx]) : Inf, axes(tbl, 1))
        tbl[r_idx, :] ./= tbl[r_idx, c_idx]
        factor = z[c_idx] / tbl[r_idx, c_idx]
        z .-= factor .* @view tbl[r_idx, :]
        for r in axes(tbl, 1)
            r == r_idx && continue
            factor = tbl[r, c_idx] / tbl[r_idx, c_idx]
            tbl[r, :] .-= factor * tbl[r_idx, :]
        end

        b_vars[r_idx] = c_idx
    end

    tbl, b_vars, z
end

# [IN]
# A: coefficient (constraint function) LHS / matrix
# b: coefficient (constraint function) RHS / vector
# c: coefficient (objective function) / vector
# goal: objective / :maximize or :minimize
# relations: relationship symbol (:le, :eq, :ge) / vector
#
# [OUT]
# tbl: initial coeeficient table (except Z)
# Z: initial coeeficient of objective function
# basic_vars: column indexes of initial basic variables
# artificial_rows: row indexes which have an artificial value
# artificial_cols: column indexes of artificial variables
function prepare_tableau(A, b, c, goal, relations)
    m, n = size(A)

    @assert m == length(b) "the size of coefficient matrix (LHS) doesn't match the length of the coefficient vector (RHS)"
    @assert m == length(relations) "the size of coefficient matrix doesn't match the length of the relations vector"
    @assert n == length(c) "the size of coefficient matrix doesn't match the length of the objective function vector"
    @assert goal ∈ (:maximize, :minimize) "the goal argument must be either :maximize or :minimize"
    @assert all(in((:le, :eq, :ge)), relations) "invalid relationship symbol is found"

    A1 = map(Float64, A)
    b′ = map(Float64, b)
    relations′ = copy(relations)

    for i in findall(signbit, b′)
        map!(x -> -x, @view A1[i, :])
        b′[i] = -b′[i]
        if relations′[i] != :eq
            relations′[i] = (relations′[i] == :le) ? :ge : le
        end
    end

    m, n = size(A1)
    A2 = Vector{Float64}[]  # slack/surplus/artificial variables
    artificial_rows = Int[]
    artificial_cols = Int[]
    basic_vars = Int[]

    c_idx = n
    for (i, sym) in pairs(relations′)
        if sym == :le
            s = zeros(Float64, m)
            s[i] = 1.0
            push!(A2, s)

            c_idx += 1
            push!(basic_vars, c_idx)
        elseif sym == :eq
            s = zeros(Float64, m)
            s[i] = 1.0
            push!(A2, s)
            push!(artificial_rows, i)

            c_idx += 1
            push!(basic_vars, c_idx)
            push!(artificial_cols, c_idx)
        else
            s = zeros(Float64, m)
            s[i] = -1.0
            push!(A2, s)
            s = zeros(Float64, m)
            s[i] = 1.0
            push!(A2, s)
            push!(artificial_rows, i)

            c_idx += 2
            push!(basic_vars, c_idx)
            push!(artificial_cols, c_idx)
        end
    end

    Z = zeros(Float64, n + length(A2) + 1)
    for (i, x) in pairs(c)
        Z[i] = (goal == :minimize) ? float(x) : -float(x)
    end

    hcat(A1, A2..., b′), Z, basic_vars, artificial_rows, artificial_cols
end

end #module
