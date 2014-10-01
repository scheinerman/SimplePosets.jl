module SimplePosets

using SimpleGraphs

type SimplePoset{T}
  D::SimpleDigraph{T}
end

end # end of module SimplePosets

