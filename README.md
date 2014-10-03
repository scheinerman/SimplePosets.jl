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

Elements
--------

* `elements(P)` returns a list of the elements in `P`
* `card(P)` returns the cardinality of `P` (number of elements).
