
module UnionFind

mutable struct DisjointSet{T <: Signed}
    elems::Vector{T}
    rank::Vector{T}
    total::T

    function DisjointSet(n::T) where T <: Signed
        n <= 0 ? error("the size of set must be positive") : new{T}(fill(-1, n), zeros(T, n), 0)
    end
end

function root!(self::DisjointSet, n)
    if self.elems[n] < 0
        n
    else
        self.elems[n] = root!(self, self.elems[n])
    end
end

function root(self::DisjointSet, n)
    if self.elems[n] < 0
        n
    else
        root(self, self.elems[n])
    end
end

function is_same(self::DisjointSet, x, y)
    root!(self, x) == root!(self, y)
end

function unite!(self::DisjointSet, x, y)
    if self.elems[x] == -1
        self.total += 1
    end
    if self.elems[y] == -1
        self.total += 1
    end

    xᵣ = root!(self, x)
    yᵣ = root!(self, y)
    grp_size = abs(self.elems[xᵣ])
    if xᵣ != yᵣ
        if self.rank[xᵣ] < self.rank[yᵣ]
            self.elems[yᵣ] += self.elems[xᵣ]
            self.elems[xᵣ] = yᵣ
            grp_size = abs(self.elems[yᵣ])
        else
            self.elems[xᵣ] += self.elems[yᵣ]
            self.elems[yᵣ] = xᵣ
            if self.rank[xᵣ] == self.rank[yᵣ]
                self.rank[xᵣ] += 1
            end
            grp_size = abs(self.elems[xᵣ])
        end
    end

    grp_size
end

function group_size(self::DisjointSet, x)
    if self.elems[x] == -1
        0
    else
        abs(self.elems[root(self, x)])
    end
end

function all_size(self::DisjointSet)
    self.total
end

function groups(self::DisjointSet)
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
