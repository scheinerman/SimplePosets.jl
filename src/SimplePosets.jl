module SimplePosets

using SimpleGraphs

export SimplePoset

type SimplePoset{T}
    D::SimpleDigraph{T}
end

end # end of module SimplePosets

