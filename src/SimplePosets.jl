module SimplePosets

using SimpleGraphs

import Base.show

import SimpleGraphs.add!, SimpleGraphs.has

export SimplePoset, elements, card, show, add!

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

# return the cardinality of this poset
card(P::SimplePoset) = NV(P.D)

# How we print posets to the terminal
function show(io::IO, P::SimplePoset)
    print(io, "$(typeof(P)) ($(card(P)) elements)")
end

# Add an element to the groundset of this poset
function add!{T}(P::SimplePoset, x)
    return add!(P.D, x)
end

# Add x<y as a relation in this poset
# function add!{T}(P::SimplePoset, x, y)

# Check if a particular element is in the ground set
has{T}(P::SimplePoset{T}, x) = has(P.D, x)

# Check if x<y holds in this poset
has{T}(P::SimplePoset{T}, x, y) = has(P.D, x, y)

end # end of module SimplePosets

