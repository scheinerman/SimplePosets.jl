module SimplePosets

using SimpleGraphs, Primes

import Base.show, Base.isequal, Base.hash
import Base.inv, Base.intersect #, Base.zeta
import Base.adjoint, Base.*, Base.+, Base./ #, Base.\
import Base.==

import SimpleGraphs.add!, SimpleGraphs.has, SimpleGraphs.delete!
import SimpleGraphs.relabel

export SimplePoset, IntPoset, check, hash, element_type
export elements, relations, incomparables
export card, show, add!, has, delete!
export above, below, interval
export maximals, minimals
export relabel
export zeta_matrix, zeta, mobius_matrix, mobius


export Chain, Antichain, Divisors, BooleanLattice, StandardExample
export RandomPoset, PartitionLattice

export ComparabilityGraph, CoverDigraph

export inv, intersect, stack, height

"""
`SimplePoset()` creates a new partially ordered set (poset) in which
the elements can be of `Any` type.

Use `SimplePoset(T)` or `SimplePlot{T}()` to create a new poset in
which the elements are of type `T`.
"""
mutable struct SimplePoset{T}
    D::SimpleDigraph{T}
    function SimplePoset{T}() where T
        D = SimpleDigraph{T}()
        forbid_loops!(D)
        new(D)
    end
end


# Create a new poset whose elements have a specific type (default Any)
SimplePoset(T::DataType=Any) = SimplePoset{T}()

# Validation check. This should not be necessary to ever use if the
# poset was properly built.
function check(P::SimplePoset)

    # cycle detection
    PP = deepcopy(P)
    while true
        bottoms = minimals(PP)
        if length(bottoms)==0
            break
        end
        for b in bottoms
            delete!(PP,b)
        end
    end
    if card(PP)>0
        warn("Cycles detected")
        return false
    end

    # transitive closure check
    Z = zeta_matrix(P)
    if countnz(Z) != countnz(Z*Z)
        warn("Not transitively closed")
        return false
    end
    return true
end

"""
`element_type(P)` returns the type of elements in this `SimplePoset`.
"""
element_type(P::SimplePoset{T}) where T = T

# Check if two posets are the same
isequal(P::SimplePoset, Q::SimplePoset) = isequal(P.D,Q.D)
==(P::SimplePoset, Q::SimplePoset) = isequal(P,Q)

# hash function for this class based on P.D
hash(P::SimplePoset, h::UInt64 = UInt64(0)) = hash(P.D,h)

# return a list of the elements in P
"""
`elements(P)` returns a list of the elements of `P`.
"""
elements(P::SimplePoset) = vlist(P.D)

# return a list of all the < relations in P
"""
`relations(P)` returns a list of ordered pairs `(u,v)` where `u` and
`v` are elements of the poset that satisfy `u<v` in `P`.
"""
relations(P::SimplePoset) = elist(P.D)

# list all pairs of elements that are incomparable to each other

"""
`incomparables(P)` returns a list of ordered pairs `(u,v)` such that
`u` and `v` are incomparable in `P`. Note that if `(u,v)` appears in
the list, we do not also include `(v,u)`.
"""
function incomparables(P::SimplePoset{T}) where T
    els = elements(P)
    n   = length(els)

    pairs = Tuple{T,T}[]
    for j=1:n-1
        for k=j+1:n
            push!(pairs, (els[j],els[k]) )
        end
    end

    filter( p -> !has(P,p[1],p[2]) && !has(P,p[2],p[1]) , pairs)
end

# return the cardinality of this poset
"""
`card(P)` returns the cardinality (number of elements) of `P`.
"""
card(P::SimplePoset) = NV(P.D)

# How we print posets to the terminal
function show(io::IO, P::SimplePoset)
    print(io, "SimplePoset{$(element_type(P))} ($(card(P)) elements)")
end

display(P::SimplePoset) = show(P)

# Add an element to the groundset of this poset
"""
`add!(P,x)` adds the element `x` to the poset with no relations to any
other elements.

`add!(P,x,y)` adds elements `x` and `y` to the poset (if they are not
already present) and, more importantly, adds the relation `x<y` as
well. This fails if adding this relation would violate transitivity.
"""
function add!(P::SimplePoset{T}, x) where T
    return add!(P.D, x)
end

# Add x<y as a relation in this poset
function add!(P::SimplePoset{T}, x, y) where T
    # start with some basic checks
    if !has(P,x)
        add!(P,x)
    end
    if !has(P,y)
        add!(P,y)
    end
    if x==y || has(P,y,x) || has(P,x,y)
        return false
    end

    U = above(P,y)
    push!(U,y)

    D = below(P,x)
    push!(D,x)

    for u in U
        for d in D
            add!(P.D,d,u)
        end
    end
    return true
end

# Delete an element from P
"""
`delete!(P,x)` deletes the element `x` from the poset `P`.

`delete!(P,x,y)` deletes the relation `x<y` from `P` (assuming that
such a relation exists in `P`). It then deletes other relations as
needed to ensure what remains is still a poset (i.e., still
transitive).
"""
delete!(P::SimplePoset, x) = delete!(P.D,x)

# Delete a relation from P (see Doc folder in github for explanation)
function delete!(P::SimplePoset, x, y)
    if !has(P,x) || !has(P,y) || x==y || !has(P,x,y)
        return false
    end

    delete!(P.D, x, y)

    for z in P.D.V
        if z==x || z==y
            continue
        end
        if has(P,x,z) && has(P,z,y)
            delete!(P.D,x,z)
            delete!(P.D,z,y)
        end
    end
    return true
end

# Check if a particular element is in the ground set

"""
`has(P,x)` checks if `x` is an element of the poset `P`.

`has(P,x,y)` checks if `x<y` is a relation in the poset `P`.
"""
has(P::SimplePoset{T}, x)  where T = has(P.D, x)

# Check if x<y holds in this poset
has(P::SimplePoset{T}, x, y) where T = has(P.D, x, y)

# return a list of all elements > xe

"""
`above(P,x)` returns a list of all elements `y` in the poset `P` for
which `x<y`.
"""
function above(P::SimplePoset, x)
    if !has(P,x)
        error("This poset does not contain ", x)
    end
    return collect(P.D.N[x])
end

"""
`below(P,x)` returns a list of all elements `y` in the poset `P` for
which `y<x`.
"""
function below(P::SimplePoset, x)
    if !has(P,x)
        error("This poset does not contain ", x)
    end
    return collect(P.D.NN[x])
end

# return a list of all elements z with x < z < y

"""
`interval(P,x,y)` returns a list of all elements `z` in the poset `P`
for which `x<z<y`.
"""
function interval(P::SimplePoset, x, y)
    A = Set(above(P,x))
    B = Set(below(P,y))
    return collect(intersect(A,B))
end

# Construct an antichain with n elements 1,2,...,n
"""
`AntiChain(n)` creates a new poset with `Int` elements `1:n` with no
relations between those elements.

`AntiChain(list)` creates a new poset with elements from `list` with
no relations between those elements.
"""
function Antichain(n::Int)
    if n < 0
        error("Number of elements must be nonnegative")
    end
    P = SimplePoset(Int)
    for e = 1:n
        add!(P,e)
    end
    return P
end

"""
`IntPoset(n)` creates a new `SimplePoset{Int}()` prepopulated with
elements `1:n` but no relations.
"""
IntPoset(n::Int) = Antichain(n)

# Construction an antichain from a list of elements
function Antichain(els::Array{T,1}) where T
    P = SimplePoset(T)
    for e in els
        add!(P,e)
    end
    return P
end

# Construct a chain 1<2<3<...<n
"""
`Chain(n)` creates a new poset whose elements are the `Int` values
`1:n` with the relations `1<2<3<...<n`.

`Chain(list)` creates a new poset whose elements are the values in
`list` with `list[1]<list[2]<...`.
"""
function Chain(n::Int)
    P = Antichain(n)
    for k=1:n
        add!(P,k)
    end
    if n > 1
        for k=1:n-1
            add!(P,k,k+1)
        end
    end
    return P
end

# Construct a chain given a list of elements
function Chain(els::Array{T,1}) where T
    P = Antichain(els)
    n = length(els)
    for k=1:n-1
        add!(P,els[k],els[k+1])
    end
    return P
end

# requires n>1, but we don't check. gives first prime factor. this is
# not exposed.
function first_prime_factor(n::Int)
    if isprime(n)
        return n
    end

    for k=2:n
        if n%k == 0
            return k
        end
    end
end

# creates the set of divisors of a positive integer. should we expose?
function divisors(n::Int)
    if n<1
        error("divisors only works on positive integers")
    end

    if n==1
        return BitSet(1)
    end

    p = first_prime_factor(n)
    if n==p
        return BitSet([1,p])
    end

    A = divisors(div(n,p))
    Alist = collect(A)

    Blist = [ p*x for x in Alist ]

    B = BitSet(Blist)

    return union(A,B)
end

# Create the poset of the divisors of a positive integer
"""
`Divisors(n)` creates a new poset whose elements are the positive
divisor of `n` (including `1` and `n` itself) in which we have the
relations `(u,v)` precisely when `u` is a factor of `v`.
"""
function Divisors(n::Int)
    if n<1
        error("Argument must be a positive integer")
    end

    A = divisors(n)
    P = SimplePoset(Int)

    for a in A
        add!(P,a)
    end

    for a in A
        for b in A
            if a!=b && b%a == 0
                add!(P,a,b)
            end
        end
    end
    return P
end

# Create the Boolean lattice poset. Elements are n-long binary
# strings.
"""
`BooleanLattice(n)` creates the Boolean lattice whose elements are `n`-long
character strings of 0s and 1s. Ordering is coordinatewise.
"""
function BooleanLattice(n::Int)
    if n<1
        error("Argument must be a positive integer")
    end

    P = SimplePoset(String)

    NN = (1<<n) - 1
    for e = 0:NN
        # add!(P,bin(e,n))
        add!(P,string(e,base=2,pad=n))
    end

    for e = 0:NN
        for f=0:NN
            if e!=f && e|f == f
                # add!(P.D,bin(e,n), bin(f,n))
                add!(P.D,string(e,base=2,pad=n),string(f,base=2,pad=n))
            end
        end
    end


    return P
end

# Helper function for RandomPoset
function vec_less(x::Array{Float64,1}, y::Array{Float64,1})
    n = length(x)
    return all([ x[k] <= y[k] for k=1:n ])
end

# Create a random d-dimensional poset with n elements

"""
`RandomPoset(n,d)` creates a random `d`-dimensional poset with
elements `1:n`.
"""
function RandomPoset(n::Int, d::Int)
    if n<1 || d<1
        error("Require n and d positive in RandomPoset(n,d)")
    end
    vectors = [ rand(d) for k=1:n ]

    P = SimplePoset(Int)
    for k=1:n
        add!(P,k)
    end

    for i=1:n
        for j=1:n
            if i!=j && vec_less(vectors[i],vectors[j])
                add!(P,i,j)
            end
        end
    end
    return P
end





# Create standard example poset. Lower level named by negatives and
# upper level by positives.

"""
`StandardExample(n)` creates a new poset with `2n` elements in two
levels. Each element on the lower level is below exactly `n-1`
elements from the upper level.

We name the lower elements `-1,-2,...,-n` and the upper elements
`1,2,...,n`. We have `-i` below all the positive elements *except*
`+i`.

```
julia> P = StandardExample(4)
SimplePoset{Int64} (8 elements)

julia> elements(P)
8-element Array{Int64,1}:
 -4
 -3
 -2
 -1
  1
  2
  3
  4

julia> relations(P)
12-element Array{Tuple{Int64,Int64},1}:
 (-4,1)
 (-4,2)
 (-4,3)
 (-3,1)
 (-3,2)
 (-3,4)
 (-2,1)
 (-2,3)
 (-2,4)
 (-1,2)
 (-1,3)
 (-1,4)
```
"""
function StandardExample(n::Int)
    if n<1
        error("Argument must be a positive integer")
    end

    P = SimplePoset(Int)
    for e=1:n
        add!(P,e)
        add!(P,-e)
        for f=1:n
            if e!=f
                add!(P.D,-e,f)
            end
        end
    end
    return P
end

# maximal and minimal elements

"""
`maximals(P)` returns a list of maximal elements of `P`.
"""
maximals(P::SimplePoset) = filter(x->out_deg(P.D,x)==0, elements(P))

"""
`minimals(P)` returns a list of minimal elements of `P`.
"""
minimals(P::SimplePoset) = filter(x->in_deg(P.D,x)==0, elements(P))

# The inverse of a poset is a new poset with the order reversed
"""
`inv(P)` creates a new poset with the same elements as `P` in which
all of `P`'s relations have been reversed. That is `(u,v)` is a
relation of `P` iff `(v,u)` is a relation of `inv(P)`.

Use `P'` as a shortcut for `inv(P)`.
"""
function inv(P::SimplePoset{T}) where T
    Q = SimplePoset(T)
    for e in P.D.V
        add!(Q,e)
    end
    for r in relations(P)
        x,y = r[1],r[2]
        add!(Q.D,y,x)
    end
    return Q
end

# We can use P' to mean inv(P) also
adjoint(P::SimplePoset) = inv(P)

# Create the intersection of two posets (must be of same element
# type). Ideally, the two posets have the same set of elements, but
# this is not necessary; if they don't we just intersect the element
# sets first.

"""
`intersect(P,Q)` constructs a new poset that is the intersection of
the two given posets (which must contain elements of the same
datatype).
"""
function intersect(P::SimplePoset{T}, Q::SimplePoset{T}) where T
    R = SimplePoset(T)
    elist = filter(x -> has(P,x), elements(Q))
    for e in elist
        add!(R,e)
    end

    rlist = filter( r -> has(P,r[1],r[2]), relations(Q))
    for r in rlist
        add!(R.D, r[1],r[2])
    end
    return R
end

# Produce the cartesian product of two posets
"""
`P*Q` is the Cartesian product of the two posets. The elements need
not be of the same type.
"""
function (*)(P::SimplePoset{S}, Q::SimplePoset{T}) where {S,T}
    PQ = SimplePoset{Tuple{S,T}}()

    for a in P.D.V
        for b in Q.D.V
            add!(PQ,(a,b))
        end
    end

    elist = elements(PQ)
    for alpha in elist
        for beta in elist
            if alpha != beta
                if has(P,alpha[1],beta[1]) || alpha[1]==beta[1]
                    if has(Q,alpha[2],beta[2]) || alpha[2]==beta[2]
                        add!(PQ.D, alpha, beta)
                    end
                end
            end
        end
    end
    return PQ
end

# Disjoint union of posets

# This seems to fix some warnings. Can't say I understand why.
function +()
    nothing
end


"""
`P+Q` is the disjoint union of the two (or more) posets. The poset
elements must all be of the same type.
"""
function (+)(x::SimplePoset{T}...) where T
    PP = SimplePoset{Tuple{T,Int}}()

    for i=1:length(x)
        P = x[i]
        for e in P.D.V
            add!(PP, (e,i))
        end

        for r in relations(P)
            a = r[1]
            b = r[2]
            add!(PP.D, (a,i), (b,i))
        end
    end

    return PP
end

# Stack a bunch of posets one atop the next. The first one in the
# argument list is at the bottom.

"""
`stack(P...)` stacks its poset arguments each on top of each
other. The first poset in the list is on the bottom.
"""
function stack(x::SimplePoset{T}...) where T
    np = length(x)
    PP = +(x...)

    for i=1:np-1
        P = x[i]
        for j=i+1:np
            Q = x[j]
            for a in P.D.V
                for b in Q.D.V
                    add!(PP.D, (a,i),(b,j))
                end
            end
        end
    end
    return PP
end

# Binary operator version of stack P/Q puts P on top while P\Q puts Q
# on top.

"""
`P/Q` stacks poset `P` on top of poset `Q`.
"""
(/)(P::SimplePoset{T}, Q::SimplePoset{T}) where T = stack(Q,P)
#
# """
# `P\Q` stacks poset `P` under poset `Q`.
# """
# (\){T}(P::SimplePoset{T}, Q::SimplePoset{T}) = stack(P,Q)
#
# # Zeta function as a matrix

"""
`zeta_matrix(P)` creates the zeta matrix of a poset `P`. The
rows/columns of this matrix are indexed by the elements of `P`. We
have a `1` in the `i,j`-position exactly when the `i`th element of `P`
is `<=` the `j`th element of `P`.

The ordering of the rows/columns does not necessarily lead to an upper
triangular matrix.
"""
function zeta_matrix(P::SimplePoset)
 elist = elements(P)
    n = length(elist)
    Z = zeros(Int, n, n)

    for i=1:n
        for j=1:n
            if i==j || has(P,elist[i],elist[j])
                Z[i,j] = 1
            end
        end
    end
    return Z
end

# Mobius function as a matrix

"""
`mobius_matrix(P)` returns the inverse of `zeta_matrix(P)`.
"""
mobius_matrix(P::SimplePoset) = round.(Int,inv(zeta_matrix(P)))

# Zeta function as a dictionary

"""
`zeta(P)` returns the zeta function of `P` as a `Dict`. If `d=zeta(P)`
then `d[u,v]==1` when `u` and `v` are elements of the poset for which
`u==v` or `(u,v)` is a relation of `P`.
"""
function zeta(P::SimplePoset{T}) where T
    z = Dict{Tuple{T,T},Int}()
    els = elements(P)
    for a in els
        for b in els
            if a==b || has(P,a,b)
                z[a,b] = 1
            else
                z[a,b] = 0
            end
        end
    end
    return z
end

# Mobius function of this poset.

"""
`mobius(P)` returns the Mobius function of the poset `P` as a `Dict`.
See `zeta`.
"""
function mobius(P::SimplePoset{T}) where T
    mu = Dict{Tuple{T,T},Int}()
    els = elements(P)
    M = mobius_matrix(P)
    n = length(els)

    for i=1:n
        a = els[i]
        for j=1:n
            b = els[j]
            mu[a,b] = M[i,j]
        end
    end
    return mu
end

# The comparability graph of a poset

"""
`ComparabilityGraph(P)` returns the comparability graph of the poset
`P`. The result is a `SimpleGraph` whose vertices are the elements of
`P` in which there is an edge `(u,v)` provided `(u,v)` or `(v,u)` is a
relation of `P`.
"""
ComparabilityGraph(P::SimplePoset) = simplify(P.D)

# The CoverDigraph of a poset P is a directed graph that has the same
# vertices as P, in which (x,y) is an edge iff x<y and there is no z with x<z<y
"""
`CoverDigraph(P)` creates a `SimpleDirectedGraph` `G` whose vertices
are the elements of `P` and in which we have the edge `(u,v)`
provided: (a) `u<v` is a relation of `P` and (b) there is no `w` in
`P` with `u<w<v`.
"""
function CoverDigraph(P::SimplePoset{T}) where T
    CD = SimpleDigraph{T}()
    for v in P.D.V
        add!(CD,v)
    end

    for r in relations(P)
        x = r[1]
        y = r[2]
        add_flag::Bool = true
        for z in P.D.V
            if has(P,x,z) && has(P,z,y)
                add_flag = false
                break
            end
        end
        if add_flag
            add!(CD,x,y)
        end
    end
    return CD
end


# Relabel the vertics of a poset based on a dictionary mapping old
# element names to new

"""
`relabel(P)` creates a new poset `P` in which the elements are
relabeled using the values `1:n` (where `n=card(P)`).

`relabel(P,d)` relabels elements according to the dictionary `d`.
"""
function relabel(P::SimplePoset{S}, label::Dict{S,T}) where {S,T}
    Q = SimplePoset{T}()
    Q.D = relabel(P.D, label)
    return Q
end

# Relabel the elements with the integers 1:n
function relabel(P::SimplePoset{S}) where S
    verts = vlist(P.D)
    n = length(verts)
    label = Dict{S,Int}()
    sizehint!(label,n)

    for idx = 1:n
        label[verts[idx]] = idx
    end

    return relabel(P,label)
end

# Compute the height by stripping off minimals repeatedly

"""
`height(P)` gives the size of a largest chain in the poset `P`.
"""
function height(P::SimplePoset)
    PP = deepcopy(P)
    result = 0

    while card(PP) > 0
        result += 1
        M = minimals(PP)
        for x in M
            delete!(PP,x)
        end
    end

    return result
end

using SimplePartitions


"""
`PartitionLattice(n)` creates the poset whose elements are the
partitions of the set `{1,2,...,n}` ordered by refinement.
"""
function PartitionLattice(n::Int)
    X = all_partitions(n)
    P = SimplePoset{Partition{Int}}()
    for x in X
        for y in X
            if x <= y
                add!(P,x,y)
            end
        end
    end
    return P
end


include("linear_extensions.jl")
include("average_height.jl")


end # end of module SimplePosets
