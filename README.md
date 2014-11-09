SimplePosets
============

This module defines a `SimplePoset` type for Julia. A *poset* is a
pair `(X,<)` where `X` is a set of elements and `<` is a relation on
`X` that is irreflexive, antisymmetric, and transitive.

This module depends on the `SimpleGraphs` module.

Basic Constructor
-----------------

Use `SimplePoset(T)` to create a new `SimplePoset` with elements
having type `T` (which defaults to `Any`).


Add/delete elements/relations
-----------------------------

Elements and relations can be added to or deleted from a poset using
these functions:

* `add!(P,x)` adds a new element `x` to the ground set of `P`.
* `add!(P,x,y)` inserts the relation `x<y` into `P`. If one (or both)
  of `x` and `y` is not in `P`, it is added as well.
* `delete!(P,x)` deletes element `x` from this poset.
* `delete!(P,x,y)` delete the relation `x<y` from `P` and for any `z`
  with `x < z < y`, also delete `x<z` and `z<y`.

More detail on element/relation addition/deletion can be found in the
document `addition-deletion.pdf` found in the `doc` folder. 

Basic inspection
----------------

* `elements(P)` returns a list of the elements in `P`
* `card(P)` returns the cardinality of `P` (number of elements).
* `relations(P)` returns a list of all pairs `(x,y)` with `x<y` in
  this poset.
* `incomparables(P)` returns a list of all incomparable pairs. If
  `(x,y)` is listed, we do not also list `(y,x)`.
* `has(P,x)` determine if `x` is an element of `P`.
* `has(P,x,y)` determine if `x<y` in the poset `P`. **Note**: Calling
  `has(P,x,x)` for an element `x` of this poset returns `false`. All
  our methods concern the strict relation `<`.
* `above(P,x)` returns a list of all elements above `x` in `P`.
* `below(P,x)` returns a list of all elements below `x` in `P`.
* `interval(P,x,y)` returns a list of all elements `z` that satisfy
  `x<z<y`. 
* `maximals(P)` returns a list of the minimal elements of `P`.
* `minimals(P)` returns a list of the minimal elements of `P`.

The following functions are not likely to be called by the casual user.

* `check(P)` returns `true` provided the internal data structures of
  `P` are valid and `false` otherwise. **Note**: There should be no
  reason to use this function if the poset is created and manipulated
  by the functions provided in this module.
* `hash(P)` computes a hash value for the poset. This enables `SimplePoset`
  objects to serve as keys in dictionaries, and so forth.

Constructors
------------

* `Antichain(n)` creates an antichain with elements `1:n`
* `Antichain(list)` creates an antichain with elements drawn from
  `list`, a one-dimensional array.
* `Boolean(n)` creates the subsets of an `n`-set poset in which
  elements are named as `n`-long binary strings.
* `Chain(n)` creates a chain with elements `1:n` in which
  `1<2<3<...<n`.
* `Chain(list)` creates a chain with elements drawn from `list` (in that
  order) in.
* `Divisors(n)` creates the poset whose elements are the divisors of
  `n` ordered by divisibility.
* `RandomPoset(n,d)` creates a random `d`-dimensional poset on `n`
  elements.
* `StandardExample(n)` creates the canonical `n`-dimensional poset
  with `2n` elements in two layers. The lower layer elements are named
  from `-1` to `-n` and the upper layer from `1` to `n`. We have
  `-i<j` exactly when `i!=j`.

Operations
----------

* `inv(P)` creates the inverse poset of `P`, i.e., we have `x<y` in
  `P` iff we have `y<x` in `inv(P)`.
* `intersect(P,Q)` creates the intersection of the two posets (which
  must be of the same element type). Typically the two posets have the
  same elements, but this is not necessary. The resulting poset's
  elements is the intersection of the two element sets, and relations
  in the result are those relations common to both `P` and `Q`.
* `P*Q` is the Cartesian product of the two posets (that may be of
  different types).
* `P+Q` is the disjoint union of two (or more) posets. The posets must
  all be of the same type. Each summand's elements is extended with an
  integer (starting at 1) corresponding to its position in the
  sum. That is, if `x` is an element of summand number `i`, then in
  the sum it becomes the element `(x,i)`. For example:

```julia
julia> P = Chain(2)+Chain(3)+Chain(4)
SimplePoset{(Int64,Int64)} (9 elements)

julia> elements(P)
9-element Array{(Int64,Int64),1}:
 (1,1)
 (1,2)
 (1,3)
 (2,1)
 (2,2)
 (2,3)
 (3,2)
 (3,3)
 (4,3)
```

* `stack(Plist...)` creates a new poset from the ones in the argument
  list by stacking one atop the next. The first poset in the list is
  at the bottom. We provide two operator versions of this: `P/Q`
  stacks `P` over `Q` and `P\Q` stacks `Q` over `P`. Element labeling
  is as in `+`.
* `relabel(P,labels)` is used to create a new poset in which the elements 
   have new names (as given by the dictionary `labels`). Calling 
   `relabel(P)` gives a new poset in which the new element names are 
   the integers `1` through `n`. Here's an example:

```julia
julia> P = Chain(3) + Chain(3)
SimplePoset{(Int64,Int64)} (6 elements)

julia> elements(P)
6-element Array{(Int64,Int64),1}:
 (1,1)
 (1,2)
 (2,1)
 (2,2)
 (3,1)
 (3,2)

julia> Q = relabel(P)
SimplePoset{Int64} (6 elements)

julia> elements(Q)
6-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6
```


Poset properties
----------------


* `ComparabilityGraph(P)` returns a `SimpleGraph` whose vertices are
  the elements of `P` and in which two distinct vertices are adjacent
  iff they are comparable in `P`.
* `CoverDigraph(P)` returns a directed graph whose vertices are the
  elements of `P` in which `(x,y)` is an edges provided both `x<y` in `P`
  and there is no `z` for which `x<z<y`. These are the edges that would
  appear in a Hasse diagram of `P`.
* `mobius(P)` creates the Mobius function for this poset (as a
  dictionary from pairs of elements to `Int` values).
* `mobius_matrix(P)` is the inverse of `zeta_matrix(P)`.
* `zeta(P)` creates the zeta function for this poset (as a dictionary
  from pairs of elements to `Int` values). We have `(x,y) ==> 1`
  provided `x==y` or `x<y`, and `(x,y) ==> 0` otherwise.
* `zeta_matrix(P)` produces the zeta matrix. Order of elements is the
  same as produced by `elements(P)`.


### To do list ###

height, width, maxchain(s), maxantichain(s),
chain cover, antichain cover (easier)

-------------------------------------------------------------------------------

### Under the hood ###


A `SimplePoset` is a wrapper around a `SimpleDigraph` object. The
functions for creating and manipulating a `SimplePoset` ensure that
the underlying digraph has directed edges `(x,y)` exactly for those
pairs of elements with `x<y`.
