# Experimental functions for linear extensions


using Memoize

export linear_extension, all_linear_extensions


"""
`linear_extension(P)` returns a linear extension of the poset `P`.
"""
function linear_extension{T}(P::SimplePoset{T})
    result = T[]
    PP = deepcopy(P)
    while card(PP)>0
        M = minimals(PP)
        append!(result, M)
        for x in M
            delete!(PP,x)
        end
    end
    return result
end



@memoize function all_linear_extensions(P::SimplePoset)
    T = element_type(P)
    result = Set{Array{T,1}}()
    if card(P) == 0
        return result
    end
    if card(P) == 1
        L = elements(P)
        push!(result, L)
        return result
    end

    M = maximals(P)
    for x in M
        PP = deepcopy(P)
        delete!(PP,x)
        PP_exts = all_linear_extensions(PP)
        for L in PP_exts
            append!(L,[x])
            push!(result, L)
        end
    end

    return result
end


@doc """
`all_linear_extensions(P)` returns the `Set` of all linear extensions
of `P`. This can take a very long time and eat up a lot of memory
(which is not released).
""" all_linear_extensions
