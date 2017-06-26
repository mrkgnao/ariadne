# Changes since version 0

This document pertains to changes between various old pre-release
versions of Opaleye and the first release to Hackage.  It is
irrelevant to you if you have only used Opaleye since its first
Hackage release.

## Changes visible in the API

### `Wire` becomes `Column`.  `ExprArr` is gone.

The most important user-visible difference between Opaleye 0 and
Opaleye 1 is that `Wire` is now called `Column`.  This is not just a
cosmetic change.  `Column` contains an entire SQL expression rather
than just a column reference.  That is, it contains what used to be
`ExprArr`.  The benefit is that manipulating SQL expressions no longer
needs the hassle of `ExprArr`.  For example, numerical operations can
be expressed succinctly

    calculation = proc () -> do
        (a, b, c) <- table -< ()
        returnA -< a + ifThenElse (b .== c) (b * c) (a / 2)

### Namespace changes

The namespace has changed from Karamaan.Opaleye to Opaleye.  Many of
the version 0 modules were very cluttered with deprecated names.  They
have been cleaned and tidied.

### Tables have type parameters for writing and reading

Tables now have two type parameters.  One indicates how to use it for
writing, the other for reading.

### `Nullable` is no longer a synonym for `Maybe`

`Nullable` is now a new type independent of `Maybe`.  `runQuery` still
converts it to `Maybe` but Opaleye-side code should use `Nullable`
instead of `Maybe`.

### `ShowConstant` doesn't exist

The `ShowConstant` typeclass for lifting Haskell values into Opaleye
does not exist anymore.  Instead there is a `PGTypes` module with
individual functions for lifting values.  If after due consideration
it seems like the typeclass was needed after all it can be added back
in.

## Internal changes

### SQL generation

Opaleye 1 uses less of HaskellDB's SQL generator.  HaskellDB's
optimizer is extremely buggy and its SQL generator does not support
`OUTER JOIN` or `VALUES`.  It would have been more difficult to work
around or patch HaskellDB than simply to write a new SQL generator for
Opaleye, so we did the latter.

### `PackMap`

Many or most of the product profunctors in use in Opaleye 0 have been
unified as values of specific type called `PackMap` which seems very
similar to a "traversal" from `Control.Lens`.  This cuts down on a lot
of boilerplate and allows unification of concepts and functionality.

## Converting from version 0

Please note that although almost all of Opaleye 0's functionality is
now present in Opaleye 1, we are still missing the implementation of
many operators and instances.  This is a very small amount of work and
would be a good starter project.  Patches for this are welcome.  For
example

* `RunQuery` is fully implemented but most of the `QueryRunner`
  instances just need to be written down.
* Support for numeric, boolean, etc. operators is fully
  implemented but many of them still need to be written down.
* Support for binary set operations and `OUTER JOIN`s is fully
  implemented but the definitions of `UNION`, `INTERSECT`,
  `INTERSECT ALL`, `RIGHT JOIN`, `FULL OUTER JOIN` etc. still need
  to be written down.

Opaleye 0 and Opaleye 1 can exist together in the same codebase
because they have different package names and different module
namespaces.  However, I would recommend converting to Opaleye 1 and
writing all new code with Opaleye 1 because it is easier to use.

Converting from Opaleye 0 to Opaleye 1 might be smoother if you
provide the following synonyms during the transition.

    type Wire = Column
    type ExprArr = (->)

    toQueryArrDef :: ExprArr a b -> QueryArr a b
    toQueryArrDef = arr

Information about how well this works in practice would be gratefully
received.

You will probably find that many identifiers have changed,
particularly fully qualified identifiers.  Theoretically a transition
package could be provided that maps from the old names to the new
names, but I suspect this is likely to be more work than just changing
all the old uses by hand.
