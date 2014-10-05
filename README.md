SimplePosets
============

Simple partially ordered sets for Julia. This will be a wrapper around
a `SimpleDigraph` object in which we enforce transitive closure and
acyclicity.

Lots more to come!!

Basic Constructor
-----------------

Using `SimplePoset(T)` to create a new `SimplePoset` with elements 
having type `T` (which defaults to `Any`).


Add/delete elements/relations
-----------------------------

* `add!(P,x)` adds a new element `x` to the ground set of `P`.
* `add!(P,x,y)` inserts the relation `x<y` into `P`.
* `delete!(P,x)` delete element `x` from this poset.

Basic inspection
----------------

* `elements(P)` returns a list of the elements in `P`
* `card(P)` returns the cardinality of `P` (number of elements).
* `relations(P)` returns a list of all pairs `(x,y)` with `x<y` in
  this poset.
* `incomparables(P)` returns a list of all incomparable pairs. If
  `(x,y)` is listed, we do not also list `(y,x)`. 
* `has(P,x)` determine if `x` is an element of `P`.
* `has(P,x,y)` determine if `x<y` in the poset `P`.
* `above(P,x)` returns a list of all elements above `x` in `P`.
* `below(P,x)` returns a list of all elements below `x` in `P`.
* `maximals(P)` returns a list of the minimal elements of `P`.
* `minimals(P)` returns a list of the minimal elements of `P`.
* `check(P)` returns `true` provided the internal data structures of
  `P` are valid and `false` otherwise. **Note**: There should be no
  reason to use this function if the poset is created and manipulated
  by the functions provided in this module.

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
* `P*Q` is the Cartesian product of the two posets.

Poset properties
----------------

Really need width, height here. But for now

* `ComparabilityGraph(P)` returns a `SimpleGraph` whose vertices are
  the elements of `P` and in which two distinct vertices are adjacent
  iff they are comparable in `P`.
* `mobius(P)` creates the Mobius function for this poset (as a
  dictionary from pairs of elements to `Int` values).
* `mobius_matrix(P)` is the inverse of `zeta_matrix(P)`.
* `zeta(P)` creates the zeta function for this poset (as a dictionary
  from pairs of elements to `Int` values). We have `(x,y) ==> 1`
  provided `x==y` or `x<y`, and `(x,y) ==> 0` otherwise. 
* `zeta_matrix(P)` produces the zeta matrix. Order of elements is the
  same as produced by `elements(P)`.


To Do
-----

cover relations, height, width, maxchain(s), maxantichain(s),
chain cover, antichain cover (easier)
relabel
