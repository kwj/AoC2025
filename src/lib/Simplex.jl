
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
    tbl, Z, b_vars, a_var_idxes, (n_x, n_s, n_a)  = prepare_tableau(A, b, c, goal, relations)

    if !iszero(n_a)
        # phase 1

        # start/end column indexes of artificial variables
        a_start, a_end = n_x + n_s + 1, n_x + n_s + n_a

        # z: objective function for phase 1
        z = zeros(Float64, length(Z))
        z[a_start:a_end] .= 1.0

        for row in a_var_idxes
            z .-= @view tbl[row, :]
        end

        standard_simplex!(tbl, b_vars, z)

        # if there is no solution, return nothing
        !isapprox(z[end], 0.0, atol = EPS) && return nothing

        # if artificial variables exist among the basic variables, remove them from the basic variables if possible
        for r_idx in findall(>=(a_start), b_vars)
            c_idx = findfirst(x -> !isapprox(x, 0.0, atol = EPS), @view tbl[r_idx, 1:(n_x + n_s)])
            isnothing(c_idx) && continue

            tbl[r_idx, :] ./= tbl[r_idx, c_idx]

            factor = z[c_idx] / tbl[r_idx, c_idx]
            z .-= factor .* @view tbl[r_idx, :]
            for r in axes(tbl, 1)
                r == r_idx && continue
                factor = tbl[r, c_idx] / tbl[r_idx, c_idx]
                tbl[r, :] .-= factor * @view tbl[r_idx, :]
            end

            b_vars[r_idx] = c_idx
        end

        deleteat!(Z, a_start:a_end)
        tbl = tbl[:, setdiff(axes(tbl, 2), a_start:a_end)]

        for row in findall(<=(n_x), b_vars)
            x = b_vars[row]
            factor = Z[x] / tbl[row, x]
            Z .-= factor .* @view tbl[row, :]
        end
    end

    standard_simplex!(tbl, b_vars, Z)

    result = zeros(Float64, n_x)
    for (idx, x) in pairs(b_vars)
        x > n_x && continue
        result[x] = tbl[idx, end]
    end

    result
end

function standard_simplex!(tbl, b_vars, z)
    while ((x, c_idx) = findmin(@view z[begin:end - 1]); x < -EPS)
        (_, r_idx) = findmin(i -> tbl[i, c_idx] > 0 ? tbl[i, end] / tbl[i, c_idx] : Inf, axes(tbl, 1))

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
# b_vars: column indexes of initial basic variables
# a_var_idxes: row indexes which have an artificial value
# tpl: # of columns (length(x), # of slack/surplus variables, # of artificial variables)
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

    A2s = Vector{Float64}[]  # slack/surplus variables
    A2a = Vector{Float64}[]  # artifiicial variables
    m, n = size(A1)
    a_var_idxes = Int[]  # row indexes which have artificial variable
    b_vars = Int[]  # column indexes of initial basic variables
    idx = n + 1
    for (i, sym) in pairs(relations′)
        if sym != :eq
            s = zeros(Float64, m)
            if sym == :le
                s[i] = 1.0
                push!(b_vars, idx)
            else
                s[i] = -1.0
            end
            push!(A2s, s)
            idx += 1
        end

        if sym != :le
            s = zeros(Float64, m)
            s[i] = 1.0
            push!(A2a, s)
            push!(a_var_idxes, i)
        end
    end

    Z = zeros(Float64, n + length(A2s) + length(A2a) + 1)
    for (i, x) in pairs(c)
        Z[i] = (goal == :minimize) ? float(x) : -float(x)
    end

    b_vars = vcat(b_vars, (n + length(A2s) + 1):(length(Z) - 1))

    hcat(A1, A2s..., A2a..., b′), Z, b_vars, a_var_idxes, (n, length(A2s), length(A2a))
end

end #module
