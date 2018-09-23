using Test
using SimplePosets
using LinearAlgebra
using SimpleGraphs

@test 1==1

P = Chain(5) + Chain(3)
@test height(P) == 5

P = StandardExample(4)
A = minimals(P)
@test length(A) == 4
B = maximals(P)
@test length(B) == 4
@test length(union(A,B))==8

P = PartitionLattice(5)
@test card(P) == 52
@test height(P) == 5
@test inv(P') == P

P = Divisors(2*3*5)
M = mobius_matrix(P)
Z = zeta_matrix(P)
n = card(P)
@test M*Z == Matrix{Int}(I,n,n)

P = BooleanLattice(3)
@test element_type(P) == String

P = RandomPoset(10,2)
@test card(P) == 10

P = Divisors(2*3*5)
@test elements(relabel(P)) == collect(1:8)
@test length(random_linear_extension(P)) == 8

d = random_average_height(P,20)
@test d[1]==0.0
