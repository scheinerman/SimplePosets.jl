using FlexLinearAlgebra

export random_average_height, true_average_height

"""
`random_average_height(P,reps=100)` gives the average height of the elements of `P`
in a random linear extension. See `random_linear_extension`.
"""
function random_average_height(P::SimplePoset{T}, reps::Int=100)::Dict{T,Float64} where T
    total = FlexVector{Float64}(elements(P))
    n = card(P)
    for j=1:reps
        L = random_linear_extension(P)
        for i=1:n
            x = L[i]
            total[x] += (i-1)
        end
    end
    d = Dict{T,Float64}()
    for x in elements(P)
        d[x] = total[x]/reps
    end
    return d
end

"""
`true_average_height(P)` gives the average height of the elements of `P`
averaged over all linear extensions of `P`. See `all_linear_extensions`.
"""
function true_average_height(P::SimplePoset{T})::Dict{T,Float64} where T
    LX_list = collect(all_linear_extensions(P))  # VERY EXPENSIVE!
    nx = length(LX_list)
    n  = card(P)

    total = FlexVector{Float64}(elements(P))

    for L in LX_list
        for i=1:n
            x = L[i]
            total[x] += (i-1)
        end
    end

    d = Dict{T,Float64}()
    for x in elements(P)
        d[x] = total[x]/nx
    end
    return d
end
