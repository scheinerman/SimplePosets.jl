module SimplePosets

using SimpleGraphs

import Base.show
export SimplePoset, elements, card, show

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

function show(io::IO, P::SimplePoset)
    print(io, "$(typeof(P)) ($(card(P)) elements)")
end

end # end of module SimplePosets

