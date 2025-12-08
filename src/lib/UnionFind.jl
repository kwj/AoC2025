
module UnionFind

mutable struct Disjoint{T <: Signed}
    elems::Vector{T}
    rank::Vector{T}
    total::T

    function Disjoint(n::T) where T <: Signed
        n <= 0 ? error("the size of set must be positive") : new{T}(fill(-1, n), zeros(n), 0)
    end
end

function root!(self::Disjoint, n)
    if self.elems[n] < 0
        n
    else
        self.elems[n] = root!(self, self.elems[n])
    end
end

function root(self::Disjoint, n)
    if self.elems[n] < 0
        n
    else
        root(self, self.elems[n])
    end
end

function is_same(self::Disjoint, x, y)
    root!(self, x) == root!(self, y)
end

function unite!(self::Disjoint, x, y)
    if self.elems[x] == -1
        self.total += 1
    end
    if self.elems[y] == -1
        self.total += 1
    end

    xᵣ = root!(self, x)
    yᵣ = root!(self, y)
    if xᵣ != yᵣ
        if self.rank[xᵣ] < self.rank[yᵣ]
            self.elems[yᵣ] += self.elems[xᵣ]
            self.elems[xᵣ] = yᵣ
        else
            self.elems[xᵣ] += self.elems[yᵣ]
            self.elems[yᵣ] = xᵣ
            if self.rank[xᵣ] == self.rank[yᵣ]
                self.rank[xᵣ] += 1
            end
        end
    end
end

function group_size(self::Disjoint, x)
    if self.elems[x] == -1
        0
    else
        abs(self.elems[root(self, x)])
    end
end

function all_size(self::Disjoint)
    self.total
end

function groups(self::Disjoint)
    members = [eltype(self.elems)[] for _ in axes(self.elems, 1)]
    for i in axes(self.elems, 1)
        push!(members[root(self, i)], i)
    end

    res = Vector{eltype(members)}()
    for i in axes(members, 1)
        if !isempty(members[i])
            push!(res, members[i])
        end
    end

    res
end

end #module
