module SimplePosets

using SimpleGraphs

import Base.show, Base.isequal, Base.hash
import Base.inv, Base.intersect, Base.zeta

import SimpleGraphs.add!, SimpleGraphs.has, SimpleGraphs.delete!
import SimpleGraphs.relabel

export SimplePoset, check, hash, element_type
export elements, relations, incomparables
export card, show, add!, has, delete!
export above, below, interval
export maximals, minimals
export relabel
export zeta_matrix, zeta, mobius_matrix, mobius


export Chain, Antichain, Divisors, Boolean, StandardExample
export RandomPoset

export ComparabilityGraph, CoverDigraph

export inv, intersect, stack, height

type SimplePoset{T}
    D::SimpleDigraph{T}
    function SimplePoset()
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

element_type{T}(P::SimplePoset{T}) = T

# Check if two posets are the same
isequal(P::SimplePoset, Q::SimplePoset) = isequal(P.D,Q.D)
==(P::SimplePoset, Q::SimplePoset) = isequal(P,Q)

# hash function for this class based on P.D
hash(P::SimplePoset, h::Uint64 = uint64(0)) = hash(P.D,h)

# return a list of the elements in P
elements(P::SimplePoset) = vlist(P.D)

# return a list of all the < relations in P
relations(P::SimplePoset) = elist(P.D)

# list all pairs of elements that are incomparable to each other
function incomparables{T}(P::SimplePoset{T})
    els = elements(P)
    n   = length(els)

    pairs = (T,T)[]
    for j=1:n-1
        for k=j+1:n
            push!(pairs, (els[j],els[k]) )
        end
    end

    filter( p -> !has(P,p[1],p[2]) && !has(P,p[2],p[1]) , pairs)
end

# return the cardinality of this poset
card(P::SimplePoset) = NV(P.D)

# How we print posets to the terminal
function show(io::IO, P::SimplePoset)
    print(io, "$(typeof(P)) ($(card(P)) elements)")
end

# Add an element to the groundset of this poset
function add!{T}(P::SimplePoset{T}, x)
    return add!(P.D, x)
end

# Add x<y as a relation in this poset
function add!{T}(P::SimplePoset{T}, x, y)
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
has{T}(P::SimplePoset{T}, x) = has(P.D, x)

# Check if x<y holds in this poset
has{T}(P::SimplePoset{T}, x, y) = has(P.D, x, y)

# return a list of all elements > x
function above(P::SimplePoset, x)
    if !has(P,x)
        error("This poset does not contain ", x)
    end
    return collect(P.D.N[x])
end

# return a list of all elements < x
function below(P::SimplePoset, x)
    if !has(P,x)
        error("This poset does not contain ", x)
    end
    return collect(P.D.NN[x])
end

# return a list of all elements z with x < z < y
function interval(P::SimplePoset, x, y)
    A = Set(above(P,x))
    B = Set(below(P,y))
    return collect(intersect(A,B))
end

# Construct an antichain with n elements 1,2,...,n
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

# Construction an antichain from a list of elements
function Antichain{T}(els::Array{T,1})
    P = SimplePoset(T)
    for e in els
        add!(P,e)
    end
    return P
end

# Construct a chain 1<2<3<...<n
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
function Chain{T}(els::Array{T,1})
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
        return IntSet(1)
    end

    p = first_prime_factor(n)
    if n==p
        return IntSet(1,p)
    end

    A = divisors(div(n,p))
    Alist = collect(A)

    Blist = [ p*x for x in Alist ]

    B = IntSet(Blist)

    return union(A,B)
end

# Create the poset of the divisors of a positive integer
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
function Boolean(n::Int)
    if n<1
        error("Argument must be a positive integer")
    end

    P = SimplePoset(ASCIIString)

    NN = (1<<n) - 1
    for e = 0:NN
        add!(P,bin(e,n))
    end

    for e = 0:NN
        for f=0:NN
            if e!=f && e|f == f
                add!(P.D,bin(e,n), bin(f,n))
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
maximals(P::SimplePoset) = filter(x->out_deg(P.D,x)==0, elements(P))
minimals(P::SimplePoset) = filter(x->in_deg(P.D,x)==0, elements(P))

# The inverse of a poset is a new poset with the order reversed
function inv{T}(P::SimplePoset{T})
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

# Create the intersection of two posets (must be of same element
# type). Ideally, the two posets have the same set of elements, but
# this is not necessary; if they don't we just intersect the element
# sets first.
function intersect{T}(P::SimplePoset{T}, Q::SimplePoset{T})
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
function *{S,T}(P::SimplePoset{S}, Q::SimplePoset{T})
    PQ = SimplePoset{(S,T)}()

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
function +{T}(x::SimplePoset{T}...)
    PP = SimplePoset{(T,Int)}()

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
function stack{T}(x::SimplePoset{T}...)
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
/{T}(P::SimplePoset{T}, Q::SimplePoset{T}) = stack(Q,P)
\{T}(P::SimplePoset{T}, Q::SimplePoset{T}) = stack(P,Q)

# Zeta function as a matrix
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
mobius_matrix(P::SimplePoset) = int(inv(zeta_matrix(P)))

# Zeta function as a dictionary
function zeta{T}(P::SimplePoset{T})
    z = Dict{(T,T),Int}()
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
function mobius{T}(P::SimplePoset{T})
    mu = Dict{(T,T),Int}()
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
ComparabilityGraph(P::SimplePoset) = simplify(P.D)

# The CoverDigraph of a poset P is a directed graph that has the same
# vertices as P, in which (x,y) is an edge iff x<y and there is no z with x<z<y
function CoverDigraph{T}(P::SimplePoset{T})
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
function relabel{S,T}(P::SimplePoset{S}, label::Dict{S,T})
    Q = SimplePoset{T}()
    Q.D = relabel(P.D, label)
    return Q
end

# Relabel the elements with the integers 1:n
function relabel{S}(P::SimplePoset{S})
    verts = vlist(P.D)
    n = length(verts)
    label = Dict{S,Int}()
    sizehint(label,n)

    for idx = 1:n
        label[verts[idx]] = idx
    end

    return relabel(P,label)
end

# Compute the height by stripping off minimals repeatedly

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

end # end of module SimplePosets

