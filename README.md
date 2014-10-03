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
* `has(P,x)` determine if `x` is an element of `P`.
* `has(P,x,y)` determine if `x<y` in the poset `P`.
* `above(P,x)` returns a list of all elements above `x` in `P`.
* `below(P,x)` returns a list of all elements below `x` in `P`.

Constructors
------------

* `Antichain(n)` creates an antichain with elements `1:n`
* `Antichain(list)` creates an antichain with elements drawn from
  `list`, a one-dimensional array.
* `Chain(n)` creates a chain with elements `1:n` in which
  `1<2<3<...<n`.
* `Chain(list)` creates a chain with elements drawn from `list` (in that
  order) in.

To Do
-----

Intersection of posets, maximal/minimal elements, cover relations,
standard posets `Boolean(n)` and others.
