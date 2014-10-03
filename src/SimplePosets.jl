module SimplePosets

using SimpleGraphs

import Base.show

import SimpleGraphs.add!, SimpleGraphs.has, SimpleGraphs.delete!

export SimplePoset, elements, relations
export card, show, add!, has
export delete! # elements only
export above, below

export Chain, Antichain

type SimplePoset{T}
    D::SimpleDigraph{T}
    function SimplePoset()
        D = SimpleDigraph{T}()
        new(D)
    end
end

# Create a new poset whose elements have a specific type (default Any)
SimplePoset(T::DataType=Any) = SimplePoset{T}()

# return a list of the elements in P
elements(P::SimplePoset) = vlist(P.D)

# return a list of all the < relations in P
relations(P::SimplePoset) = elist(P.D)

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

# return a liset of all elements < x
function below(P::SimplePoset, x)
    if !has(P,x)
        error("This poset does not contain ", x)
    end
    return collect(P.D.NN[x])
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

    
end # end of module SimplePosets

