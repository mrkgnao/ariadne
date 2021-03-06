{-# LANGUAGE Arrows                #-}
{-# LANGUAGE FlexibleContexts      #-}

{-# LANGUAGE MultiParamTypeClasses #-}

{-# LANGUAGE DataKinds               #-}
{-# LANGUAGE FlexibleContexts        #-}
{-# LANGUAGE FlexibleInstances       #-}
{-# LANGUAGE PolyKinds               #-}
{-# LANGUAGE ScopedTypeVariables     #-}
{-# LANGUAGE TypeApplications        #-}
{-# LANGUAGE TypeFamilies            #-}
{-# LANGUAGE UndecidableInstances    #-}
{-# LANGUAGE UndecidableSuperClasses #-}
{-# OPTIONS_GHC -Wno-redundant-constraints #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Edible.Operators where

import Prelude hiding (not)

import           Edible.AggregateTypes                    (Aggregator, aggregate,
                                                      groupBy)
import           Edible.Column                       (Column)
import           Edible.QueryArr                     (Query)

import           Control.Applicative                 (Applicative, pure, (<*>))

import qualified Data.Profunctor                     as P
import qualified Data.Profunctor.Product             as PP
import           Data.Profunctor.Product.Default     (Default, def)

import qualified Control.Arrow                       as A
import qualified Data.Foldable                       as F
import qualified Data.List.NonEmpty                  as NEL

import           Edible.Internal.Column              (Column (Column),
                                                      unsafeCase_, unsafeGt,
                                                      unsafeIfThenElse)
import qualified Edible.Internal.Column              as C
import           Edible.Internal.Helpers             ((.:))
import qualified Edible.Internal.PrimQuery           as PQ
import           Edible.Internal.QueryArr            (Query,
                                                      QueryArr (QueryArr),
                                                      runSimpleQueryArr)
import qualified Edible.Order                        as Ord
import qualified Edible.PGTypes                      as T

import qualified Edible.Column                       as Column
import qualified Edible.Join                         as Join

import qualified Edible.Internal.HaskellDB.PrimQuery as HPQ

import qualified Data.Profunctor.Product.Default     as D

import           Control.Lens                        ()
import qualified Data.ByteString
import qualified Data.CaseInsensitive
import           Data.Foldable
import           Data.Semigroup                      (Semigroup (..))
import qualified Edible.Internal.Column              as OI
import qualified Edible.Internal.HaskellDB.PrimQuery as HDB
import qualified GHC.TypeLits                        as GHC

import qualified Edible.Column                       as O
import qualified Edible.Order                        as O
import           Edible.PGTypes                      (PGNumeric)
import qualified Edible.PGTypes                      as O


import           Edible.RunQuery               (SomeColumn (..),
                                                      unsafeFunExpr)
import           Edible.Internal.Kol                  (CastKol, Kol (..),
                                                      PgTyped (..), ToKol (..),
                                                      kolArray, liftKol1,
                                                      liftKol2, liftKol3,
                                                      unsaferCastKol,
                                                      unsaferCoerceKol)
import           Edible.Internal.Koln                 (Koln (..))

import Edible.Internal.Operators (EqPP(..), IfPP(..),ifExplict)
import qualified Edible.Internal.Operators as EI

-------------------------------------------------------------------------------
-- Semigroups, Monoids

instance Semigroup (Kol O.PGText) where
  (<>) = liftKol2 (OI.binOp (HDB.:||))

instance Monoid (Kol O.PGText) where
  mempty = kol ""
  mappend = (<>)

---
instance Semigroup (Kol O.PGCitext) where
  (<>) ka kb = unsaferCoerceKol
    (mappend (unsaferCoerceKol ka :: Kol O.PGText)
             (unsaferCoerceKol kb :: Kol O.PGText))

instance Monoid (Kol O.PGCitext) where
  mempty = kol (Data.CaseInsensitive.mk "")
  mappend = (<>)

---
instance Semigroup (Kol O.PGBytea) where
  (<>) = liftKol2 (OI.binOp (HDB.:||))

instance Monoid (Kol O.PGBytea) where
  mempty = kol Data.ByteString.empty
  mappend = (<>)

---
instance PgTyped a => Semigroup (Kol (O.PGArray a)) where
  (<>) = liftKol2 (\x y -> unsafeFunExpr "array_cat" [SomeColumn x, SomeColumn y])

instance forall a. PgTyped a => Monoid (Kol (O.PGArray a)) where
  mempty = kolArray ([] :: [Kol a])
  mappend = (<>)

-------------------------------------------------------------------------------
-- 'Num' and related operations

-- | A @'PgNum' a@ instance gives you a @'Num' ('Kol' a)@ instance for free.
class (PgTyped a, OI.PGNum (PgType a)) => PgNum (a :: k)

instance PgNum O.PGInt2
instance PgNum O.PGInt4
instance PgNum O.PGInt8
instance PgNum O.PGFloat4
instance PgNum O.PGFloat8
instance GHC.KnownNat s => PgNum (PGNumeric s)

instance (PgNum a, Num (O.Column (PgType a))) => Num (Kol a) where
  fromInteger = Kol . fromInteger
  (*) = liftKol2 (*)
  (+) = liftKol2 (+)
  (-) = liftKol2 (-)
  abs = liftKol1 abs
  negate = liftKol1 negate
  signum = liftKol1 signum

-- | Sql operator @%@
modulo :: PgNum a => Kol a -> Kol a -> Kol a
modulo = liftKol2 (OI.binOp HDB.OpMod)

-------------------------------------------------------------------------------

-- | A 'PgIntegral' is guaranteed to be an integral type.
class PgTyped a => PgIntegral (a :: k)

instance PgIntegral O.PGInt2
instance PgIntegral O.PGInt4
instance PgIntegral O.PGInt8
instance PgIntegral (PGNumeric 0)

itruncate :: (PgFloating a, PgIntegral b) => Kol a -> Kol b
itruncate = liftKol1 (unsafeFunExpr "trunc" . pure . SomeColumn)

iround :: (PgFloating a, PgIntegral b) => Kol a -> Kol b
iround = liftKol1 (unsafeFunExpr "round" . pure . SomeColumn)

iceil :: (PgFloating a, PgIntegral b) => Kol a -> Kol b
iceil = liftKol1 (unsafeFunExpr "ceil" . pure . SomeColumn)

ifloor :: (PgFloating a, PgIntegral b) => Kol a -> Kol b
ifloor = liftKol1 (unsafeFunExpr "floor" . pure . SomeColumn)

-------------------------------------------------------------------------------

-- | A @'PgFractional' a@ instance gives you a @'Fractional' ('Kol' a)@ instance
-- for free.
class (PgTyped a, PgNum a, OI.PGFractional (PgType a)) => PgFractional (a :: k)

instance PgFractional O.PGFloat4
instance PgFractional O.PGFloat8
instance GHC.KnownNat s => PgFractional (PGNumeric s)

instance
    ( PgTyped a, PgFractional a
    , Fractional (O.Column (PgType a))
    , Num (O.Column (PgType a))
    ) => Fractional (Kol a) where
  fromRational = Kol . fromRational
  (/) = liftKol2 (/)

-------------------------------------------------------------------------------
-- | A 'PgFloating' instance gives you 'Floating'-support.
class (PgTyped a, PgFractional a) => PgFloating (a :: k)

instance PgFloating O.PGFloat4
instance PgFloating O.PGFloat8

-- | @2.718281828459045@
euler's :: PgFloating a => Kol a
euler's = unsaferCastKol (kol (2.718281828459045 :: Double) :: Kol O.PGFloat8)
{-# INLINE euler's #-}

instance
    ( PgTyped a
    , PgFloating a
    , Fractional (Kol a)
    , PgFloating (Kol a)
    ) => Floating (Kol a) where
  pi = Kol (unsafeFunExpr "pi" [])
  exp = liftKol1 (unsafeFunExpr "exp" . pure . SomeColumn)
  log = liftKol1 (unsafeFunExpr "log" . pure . SomeColumn)
  sqrt = liftKol1 (unsafeFunExpr "sqrt" . pure . SomeColumn)
  (**) = liftKol2 (\base ex -> unsafeFunExpr "power" [SomeColumn base, SomeColumn ex])
  logBase = liftKol2 (\base n -> unsafeFunExpr "log" [SomeColumn base, SomeColumn n])
  sin = liftKol1 (unsafeFunExpr "sin" . pure . SomeColumn)
  cos = liftKol1 (unsafeFunExpr "cos" . pure . SomeColumn)
  tan = liftKol1 (unsafeFunExpr "tan" . pure . SomeColumn)
  asin = liftKol1 (unsafeFunExpr "asin" . pure . SomeColumn)
  acos = liftKol1 (unsafeFunExpr "acos" . pure . SomeColumn)
  atan = liftKol1 (unsafeFunExpr "atan" . pure . SomeColumn)
  -- Not the most efficient implementations, but PostgreSQL doesn't provide
  -- builtin support for hyperbolic functions. We add these for completeness,
  -- so that we can implement the 'Floating' typeclass in full.
  sinh x = ((euler's ** x) - (euler's ** (negate x))) / fromInteger 2
  cosh x = ((euler's ** x) + (euler's ** (negate x))) / fromInteger 2
  tanh x = ((euler's ** x) - (euler's ** (negate x)))
         / ((euler's ** x) + (euler's ** (negate x)))
  asinh x = log (x + sqrt ((x ** fromInteger 2) + fromInteger 1))
  acosh x = log (x + sqrt ((x ** fromInteger 2) - fromInteger 1))
  atanh x = log ((fromInteger 1 + x) / (fromInteger 1 - x)) / fromInteger 2

-------------------------------------------------------------------------------

-- Booleans.

-- | Like 'Prelude.bool', @'matchBool' f t x@ evaluates to @f@ if @x@ is false,
-- otherwise it evaluates to @t@.
matchBool :: PgTyped a => Kol a -> Kol a -> Kol O.PGBool -> Kol a
matchBool = liftKol3 (\f' t' x' -> ifThenElse x' t' f')

-- | Logical NOT.
--
-- Note: This function can take any of 'Kol' and 'Koln' argument, with the
-- return type being fully determined by it. The valid combinations are:
--
-- @
-- 'lnot' :: 'Kol'  'O.PGBool' -> 'Kol'  'O.PGBool'
-- 'lnot' :: 'Koln' 'O.PGBool' -> 'Koln' 'O.PGBool'
-- @
lnot :: Kol O.PGBool -> Kol O.PGBool
lnot = liftKol1 not

-- | Logical OR. See 'eq' for possible argument types.
lor :: Kol O.PGBool -> Kol O.PGBool -> Kol O.PGBool
lor = liftKol2 (.||)

-- | Whether any of the given 'O.PGBool's is true.
--
-- Notice that 'lor' is more general that 'lors', as it doesn't restrict @kol@.
--
-- Mnemonic reminder: Logical ORs.
lors :: Foldable f => f (Kol O.PGBool) -> Kol O.PGBool
lors = foldl' lor (kol False)

-- Logical AND. See 'eq' for possible argument types.
land :: Kol O.PGBool -> Kol O.PGBool -> Kol O.PGBool
land = liftKol2 (.&&)

-- | Whether all of the given 'O.PGBool's are true.
--
-- Notice that 'land' is more general that 'lands', as it doesn't restrict
-- @kol@.
--
-- Mnemonic reminder: Logical ANDs.
lands :: Foldable f => f (Kol O.PGBool) -> Kol O.PGBool
lands = foldl' land (kol True)

--------------------------------------------------------------------------------
-- Equality

-- | A @'PgEq' a@ instance states that @a@ can be compared for equality.
class PgTyped a => PgEq (a :: k)

instance PgEq O.PGBool
instance PgEq O.PGBytea
instance PgEq O.PGCitext
instance PgEq O.PGDate
instance PgEq O.PGFloat4
instance PgEq O.PGFloat8
instance PgEq O.PGInt2
instance PgEq O.PGInt4
instance PgEq O.PGInt8
instance PgEq O.PGJsonb
instance PgEq O.PGJson
instance PgEq O.PGText
instance PgEq O.PGTimestamptz
instance PgEq O.PGTimestamp
instance PgEq O.PGTime
instance PgEq O.PGUuid
instance PgEq (PGNumeric s)

-- | Whether two column values are equal.
--
-- Mnemonic reminder: EQual.
eq :: PgEq a => Kol a -> Kol a -> Kol O.PGBool
eq = liftKol2 (.==)

-- | Whether the given value is a member of the given collection.
member :: (PgEq a, Foldable f) => Kol a -> f (Kol a) -> Kol O.PGBool
member ka fkas = Kol (in_ (map unKol (toList fkas)) (unKol ka))

--------------------------------------------------------------------------------
-- Ordering

-- | A 'PgOrd' instance says that @a@ has an ordering. See 'orderBy'.
class (PgTyped a, O.PGOrd (PgType a)) => PgOrd (a :: k)
instance (PgTyped a, O.PGOrd (PgType a)) => PgOrd a

-- | Whether the first argument is less than the second.
--
-- Mnemonic reminder: Less Than.
lt :: PgOrd a => Kol a -> Kol a -> Kol O.PGBool
lt = liftKol2 (.<)

-- | Whether the first argument is less than or equal to the second.
--
-- Mnemonic reminder: Less Than or Equal.
lte :: PgOrd a => Kol a -> Kol a -> Kol O.PGBool
lte = liftKol2 (.<=)

-- | Whether the first argument is greater than the second.
--
-- Mnemonic reminder: Greater Than.
gt :: PgOrd a => Kol a -> Kol a -> Kol O.PGBool
gt = liftKol2 (.>)

-- | Whether the first argument is greater than or equal to the second.
--
-- Mnemonic reminder: Greater Than or Equal.
gte :: PgOrd a => Kol a -> Kol a -> Kol O.PGBool
gte = liftKol2 (.>=)

--------------------------------------------------------------------------------
-- Bitwise

-- | Only 'PgBitwise' instance can be used with bitwise operators 'btwand',
-- 'bword', 'bwxor', 'bwnot', 'bwsl' and 'bwsr'.
class PgTyped a => PgBitwise (a :: k)

instance PgBitwise O.PGInt2
instance PgBitwise O.PGInt4
instance PgBitwise O.PGInt8
-- instance PgBitwise O.PGBitstring ?

-- | Bitwise AND. Sql operator: @&@
bwand :: PgBitwise a => Kol a -> Kol a -> Kol a
bwand = liftKol2 (OI.binOp (HDB.:&))

-- | Bitwise OR. Sql operator: @|@
bwor :: PgBitwise a => Kol a -> Kol a -> Kol a
bwor = liftKol2 (OI.binOp (HDB.:|))

-- | Bitwise XOR. Sql operator: @#@
bwxor :: PgBitwise a => Kol a -> Kol a -> Kol a
bwxor = liftKol2 (OI.binOp (HDB.:^))

-- | Bitwise NOT. Sql operator: @~@
bwnot :: PgBitwise a => Kol a -> Kol a
bwnot = liftKol1 (OI.unOp (HDB.UnOpOther "~"))

-- | Bitwise shift left. Sql operator: @<<@
--
-- @'bwsl' a n@ shifts @a@ to the right @n@ positions. Translates to @a << n@ in
-- the generated SQL.
bwsl :: (PgBitwise a, PgIntegral b) => Kol a -> Kol b -> Kol a
bwsl = liftKol2 (OI.binOp (HDB.OpOther ("<<")))

-- | Bitwise shift right. Sql operator: @>>@
--
-- @'bwsr' a n@ shifts @a@ to the right @n@ positions. Translates to @a >> n@ in
-- the generated SQL.
bwsr :: (PgBitwise a, PgIntegral b) => Kol a -> Kol b -> Kol a
bwsr = liftKol2 (OI.binOp (HDB.OpOther (">>")))

--------------------------------------------------------------------------------
-- Time

-- Convert a PostgreSQL @timestamptz@ to a @timestamp@ at a given timezone.
--
-- Notice that a @timestamp@ value is usually meaningless unless you also know
-- the timezone where that @timestamp@ happens. In other words, you should
-- store the passed in @'Kol' zone@ somewhere.
--
-- Warning: Dealing with @timestamp@ values in PostgreSQL is very error prone
-- unless you really know what you are doing.  Quite likely you shouldn't be
-- using @timestamp@ values in PostgreSQL unless you are storing distant dates
-- in the future for which the precise UTC time can't be known (e.g., can you
-- tell the UTC time for January 1 4045, 00:00:00 in Peru? Me neither, as I
-- have no idea in what timezone Peru will be in year 4045, so I can't convert
-- that to UTC).
--
-- Law 1: Provided the timezone database information stays the same, the
-- following equality holds:
--
-- @
-- 'toTimestamptz' zone . 'toTimestamp' zone === 'id'
-- 'toTimestamp' zone . 'toTimestamptz' zone === 'id'
-- @
toTimestamptz
  :: ( PgTyped zone, PgType zone ~ O.PGText
     , PgTyped a, PgType a ~ O.PGTimestamptz
     , PgTyped b, PgType b ~ O.PGTimestamp )
  => Kol zone -> Kol a -> Kol b
toTimestamptz = liftKol2
  (\zone a -> unsafeFunExpr "timezone" [SomeColumn zone, SomeColumn a])

-- Convert a PostgreSQL @timestamp@ to a @timestamptz@, making the assumption
-- that the given @timestamp@ happens at the given timezone.
--
-- Law 1: Provided the timezone database information stays the same, the
-- following equality holds:
--
-- @
-- 'toTimestamptz' zone . 'toTimestamp' zone === 'id'
-- 'toTimestamp' zone . 'toTimestamptz' zone === 'id'
-- @
toTimestamp
  :: ( PgTyped zone, PgType zone ~ O.PGText
     , PgTyped a, PgType a ~ O.PGTimestamp
     , PgTyped b, PgType b ~ O.PGTimestamptz )
  => Kol zone -> Kol a -> Kol b
toTimestamp = liftKol2
  (\zone a -> unsafeFunExpr "timezone" [SomeColumn zone, SomeColumn a])

unsafeFunExpr__date_part :: (PgTyped tsy, PgTyped b) => HDB.Name -> Kol tsy -> Kol b
unsafeFunExpr__date_part n = unsaferCastKol @O.PGFloat8 . liftKol1
   (\x -> unsafeFunExpr "date_part" [SomeColumn (O.pgString n), SomeColumn x])

tstzEpoch :: Kol O.PGTimestamptz -> Kol O.PGFloat8
tstzEpoch = unsafeFunExpr__date_part "epoch"

tsCentury :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsCentury = unsafeFunExpr__date_part "century"

tsDay :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsDay = unsafeFunExpr__date_part "day"

tsDayOfTheWeek :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsDayOfTheWeek = unsafeFunExpr__date_part "dow"

tsDayOfTheWeekISO8601 :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsDayOfTheWeekISO8601 = unsafeFunExpr__date_part "isodow"

tsDayOfTheYear :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsDayOfTheYear = unsafeFunExpr__date_part "doy"

tsDecade :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsDecade = unsafeFunExpr__date_part "decade"

tsHour :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsHour = unsafeFunExpr__date_part "hour"

tsMicroseconds :: (PgIntegral b, CastKol O.PGInt4 b) => Kol O.PGTimestamp -> Kol b
tsMicroseconds = unsafeFunExpr__date_part "microseconds"

tsMillenium :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsMillenium = unsafeFunExpr__date_part "millenium"

tsMilliseconds :: (PgIntegral b, CastKol O.PGInt4 b) => Kol O.PGTimestamp -> Kol b
tsMilliseconds = unsafeFunExpr__date_part "milliseconds"

tsMinute :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsMinute = unsafeFunExpr__date_part "minute"

tsMonth :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsMonth = unsafeFunExpr__date_part "month"

tsQuarter :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsQuarter = unsafeFunExpr__date_part "quarter"

tsSecond :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsSecond = unsafeFunExpr__date_part "second"

tsWeekISO8601 :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsWeekISO8601 = unsafeFunExpr__date_part "week"

tsYear :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsYear = unsafeFunExpr__date_part "year"

tsYearISO8601 :: (PgIntegral b) => Kol O.PGTimestamp -> Kol b
tsYearISO8601 = unsafeFunExpr__date_part "isoyear"

-- | Time when the current transaction started.
--
-- Sql function: @transaction_timestamp()@, @now()@.
nowTransaction :: Kol O.PGTimestamptz
nowTransaction = Kol (unsafeFunExpr "transaction_timestamp" [])

-- | Time when the current statement started.
--
-- SqlFunction: @statement_timestamp()@.
nowStatement :: Kol O.PGTimestamptz
nowStatement = Kol (unsafeFunExpr "statement_timestamp" [])

-- | Current clock time.
--
-- SqlFunction: @clock_timestamp()@.
nowClock :: Kol O.PGTimestamptz
nowClock = Kol (unsafeFunExpr "clock_timestamp" [])

--------------------------------------------------------------------------------
-- Regular expressions

-- | Whether the given regular expression matches the given text.
--
-- Sql operator: @~@
reMatch
  :: (O.PGText ~ regex, O.PGText ~ source)
  => Kol regex
  -> Kol source
  -> Kol O.PGBool  -- ^ Is there a match?
reMatch = liftKol2 (flip (OI.binOp (HDB.OpOther "~")))

-- | Extract a substring matching the given regular expression. If there is no
-- match, then @nul@ is returned.
--
-- Sql function: @substring()@.
reSub
  :: (O.PGText ~ regex, O.PGText ~ source)
  => Kol regex
  -- ^ Regular expression. If the pattern contains any parentheses, the portion
  -- of the text that matched the first parenthesized subexpression (the one
  -- whose left parenthesis comes first) is returned. See Section 9.1 of the
  -- PostgreSQL manual to understand the syntax.
  -> Kol source
  -> Koln O.PGText -- ^ Possibly matched substring.
reSub (Kol re) (Kol a) =
  Koln (unsafeFunExpr "substring" [SomeColumn a, SomeColumn re])

-- | Replaces with @replacement@ in the given @source@ string the /first/
-- substring matching the regular expression @regex@.
--
-- Sql function: @regexp_replace(_, _, _)@.
reReplace
  :: (O.PGText ~ regex, O.PGText ~ source, O.PGText ~ replacement)
  => Kol regex
  -- ^ Regular expression. See Section 9.1 of the PostgreSQL manual to
  -- understand the syntax.
  -> Kol replacement
  -- ^ Replacement expression. See Section 9.1 of the PostgreSQL manual to
  -- understand the syntax.
  -> Kol source
  -> Kol O.PGText
reReplace (Kol re) (Kol rep) (Kol s) = Kol $ unsafeFunExpr "regexp_replace"
   [SomeColumn s, SomeColumn re, SomeColumn rep]

-- | Like 'reReplace', but replaces /all/ of the substrings matching the
-- pattern, not just the first one.
--
-- Sql function: @regexp_replace(_, _, _, 'g')@.
reReplaceg
  :: (O.PGText ~ regex, O.PGText ~ source, O.PGText ~ replacement)
  => Kol regex
  -- ^ Regular expression. See Section 9.1 of the PostgreSQL manual to
  -- understand the syntax.
  -> Kol replacement
  -- ^ Replacement expression. See Section 9.1 of the PostgreSQL manual to
  -- understand the syntax.
  -> Kol source
  -> Kol O.PGText
reReplaceg (Kol re) (Kol rep) (Kol s) = Kol $ unsafeFunExpr "regexp_replace"
   [SomeColumn s, SomeColumn re, SomeColumn rep, SomeColumn (O.pgString "g")]

-- | Split the @source@ string using the given Regular Expression as a
-- delimiter.
--
-- If there is no match to the pattern, the function an array with just one
-- element: the original string. If there is at least one match,
-- for each match it returns the text from the end of the last match (or the
-- beginning of the string) to the beginning of the match. When there are no
-- more matches, it returns the text from the end of the last match to the end
-- of the string.
--
-- Sql function: @regexp_split_to_array(source, regexp)@.
reSplit
  :: (O.PGText ~ regex, O.PGText ~ source)
  => Kol regex
  -- ^ Regular expression. See Section 9.1 of the PostgreSQL manual to
  -- understand the syntax.
  -> Kol source
  -> Kol (O.PGArray O.PGText)
reSplit (Kol re) (Kol s) = Kol $ unsafeFunExpr "regexp_split_to_array"
   [SomeColumn s, SomeColumn re]

--------------------------------------------------------------------------------
-- LIKE clauses

-- | Whether the given LIKE clause matches the given text (case insensitive).
--
-- Sql operator: @ILIKE@
ilike
  :: (O.PGText ~ regex, O.PGText ~ source)
  => Kol regex
  -> Kol source
  -> Kol O.PGBool  -- ^ Is there a match?
ilike = liftKol2 (OI.binOp (HDB.OpOther "ILIKE"))

-- | Whether the given LIKE clause matches the given text.
--
-- Sql operator: @LIKE@
like
  :: (O.PGText ~ regex, O.PGText ~ source)
  => Kol regex
  -> Kol source
  -> Kol O.PGBool  -- ^ Is there a match?
like = liftKol2 (OI.binOp (HDB.OpOther "LIKE"))

-- | Operators on 'Column's.  Please note that numeric 'Column' types
-- are instances of 'Num', so you can use '*', '/', '+', '-' on them.
-- | Remove duplicate rows from the 'Query'.
--
-- Example type specialization:
--
-- @
-- distinct :: Query (Column a, Column b) -> Query (Column a, Column b)
-- @
--
-- Assuming the @makeAdaptorAndInstance@ splice has been run for the product type @Foo@:
--
-- @
-- distinct :: Query (Foo (Column a) (Column b) (Column c)) -> Query (Foo (Column a) (Column b) (Column c))
-- @
--
-- By design there is no @distinct@ function of type @QueryArr a b ->
-- QueryArr a b@.  Such a function would allow violation of SQL's
-- scoping rules and lead to invalid queries.
distinctExplicit :: Distinctspec columns columns'
                 -> Query columns -> Query columns'
distinctExplicit (Distinctspec agg) = aggregate agg

newtype Distinctspec a b = Distinctspec (Aggregator a b)

instance Default Distinctspec (Column a) (Column a) where
  def = Distinctspec groupBy

-- { Boilerplate instances

instance Functor (Distinctspec a) where
  fmap f (Distinctspec g) = Distinctspec (fmap f g)

instance Applicative (Distinctspec a) where
  pure = Distinctspec . pure
  Distinctspec f <*> Distinctspec x = Distinctspec (f <*> x)

instance P.Profunctor Distinctspec where
  dimap f g (Distinctspec q) = Distinctspec (P.dimap f g q)

instance PP.ProductProfunctor Distinctspec where
  empty = PP.defaultEmpty
  (***!) = PP.defaultProfunctorProduct

instance PP.SumProfunctor Distinctspec where
  Distinctspec x1 +++! Distinctspec x2 = Distinctspec (x1 PP.+++! x2)

-- }

-- We implement distinct simply by grouping by all columns.  We could
-- instead implement it as SQL's DISTINCT but implementing it in terms
-- of something else that we already have is easier at this point.

distinctA :: Default Distinctspec columns columns =>
            Query columns -> Query columns
distinctA = distinctExplicit def

-- * Restriction operators

{-| Restrict query results to a particular condition.  Corresponds to
the guard method of the MonadPlus class.  You would typically use
'restrict' if you want to use 'A.Arrow' notation.  -}
restrictA :: QueryArr (Column T.PGBool) ()
restrictA = QueryArr f where
  f (Column predicate, primQ, t0) = ((), PQ.restrict predicate primQ, t0)

{-| Add a @WHERE EXISTS@ clause to the current query. -}
exists :: QueryArr a b -> QueryArr a ()
exists criteria = QueryArr f where
  f (a, primQ, t0) = ((), PQ.exists primQ existsQ, t1) where
    (_, existsQ, t1) = runSimpleQueryArr criteria (a, t0)

{-| Add a @WHERE EXISTS@ clause to the current query. -}
notExists :: QueryArr a b -> QueryArr a ()
notExists criteria = QueryArr f where
  f (a, primQ, t0) = ((), PQ.notExists primQ existsQ, t1) where
    (_, existsQ, t1) = runSimpleQueryArr criteria (a, t0)

{-| Filter a 'QueryArr' to only those rows where the given condition
holds.  This is the 'QueryArr' equivalent of 'Prelude.filter' from the
'Prelude'.  You would typically use 'keepWhen' if you want to use a
\"point free\" style.-}
keepWhen :: (a -> Column T.PGBool) -> QueryArr a a
keepWhen p = proc a -> do
  restrictA  -< p a
  A.returnA -< a

-- * Equality operators

infix 4 .==
(.==) :: Column a -> Column a -> Column T.PGBool
(.==) = C.binOp (HPQ.:==)

infix 4 ./=
(./=) :: Column a -> Column a -> Column T.PGBool
(./=) = C.binOp (HPQ.:<>)

infix 4 .===
-- | A polymorphic equality operator that works for all types that you
-- have run `makeAdaptorAndInstance` on.  This may be unified with
-- `.==` in a future version.
(.===) :: D.Default EqPP columns columns => columns -> columns -> Column T.PGBool
(.===) = (EI..==)

infix 4 ./==
-- | A polymorphic inequality operator that works for all types that
-- you have run `makeAdaptorAndInstance` on.  This may be unified with
-- `./=` in a future version.
(./==) :: D.Default EqPP columns columns => columns -> columns -> Column T.PGBool
(./==) = Edible.Operators.not .: (EI..==)

-- * Comparison operators

infix 4 .>
(.>) :: Ord.PGOrd a => Column a -> Column a -> Column T.PGBool
(.>) = unsafeGt

infix 4 .<
(.<) :: Ord.PGOrd a => Column a -> Column a -> Column T.PGBool
(.<) = C.binOp (HPQ.:<)

infix 4 .<=
(.<=) :: Ord.PGOrd a => Column a -> Column a -> Column T.PGBool
(.<=) = C.binOp (HPQ.:<=)

infix 4 .>=
(.>=) :: Ord.PGOrd a => Column a -> Column a -> Column T.PGBool
(.>=) = C.binOp (HPQ.:>=)

-- * Numerical operators

quot_ :: C.PGIntegral a => Column a -> Column a -> Column a
quot_ = C.binOp (HPQ.:/)

-- | The remainder of division named after 'Prelude.rem'.
-- It maps to 'MOD' ('%') in Postgres, confusingly described as "modulo (remainder)".
rem_ :: C.PGIntegral a => Column a -> Column a -> Column a
rem_ = C.binOp HPQ.OpMod

-- * Conditional operators

case_ :: [(Column T.PGBool, Column a)] -> Column a -> Column a
case_ = unsafeCase_

-- | Monomorphic if\/then\/else.
--
-- This may be replaced by 'ifThenElseMany' in a future version.
ifThenElse :: Column T.PGBool -> Column a -> Column a -> Column a
ifThenElse = unsafeIfThenElse

-- | Polymorphic if\/then\/else.
ifThenElseMany :: D.Default IfPP columns columns
               => Column T.PGBool
               -> columns
               -> columns
               -> columns
ifThenElseMany = ifExplict D.def

-- * Logical operators

infixr 2 .||

-- | Boolean or
(.||) :: Column T.PGBool -> Column T.PGBool -> Column T.PGBool
(.||) = C.binOp HPQ.OpOr

infixr 3 .&&

-- | Boolean and
(.&&) :: Column T.PGBool -> Column T.PGBool -> Column T.PGBool
(.&&) = (.&&)

-- | Boolean not
not :: Column T.PGBool -> Column T.PGBool
not = C.unOp HPQ.OpNot

-- | True when any element of the container is true
ors :: F.Foldable f => f (Column T.PGBool) -> Column T.PGBool
ors = F.foldl' (.||) (T.pgBool False)

-- * Text operators

-- | Concatenate 'Column' 'T.PGText'
(.++) :: Column T.PGText -> Column T.PGText -> Column T.PGText
(.++) = C.binOp (HPQ.:||)

-- | To lowercase
lower :: Column T.PGText -> Column T.PGText
lower = C.unOp HPQ.OpLower

-- | To uppercase
upper :: Column T.PGText -> Column T.PGText
upper = C.unOp HPQ.OpUpper

-- | Postgres @LIKE@ operator
like_ :: Column T.PGText -> Column T.PGText -> Column T.PGBool
like_ = C.binOp HPQ.OpLike

-- | Postgres @ILIKE@ operator
ilike_ :: Column T.PGText -> Column T.PGText -> Column T.PGBool
ilike_ = C.binOp HPQ.OpILike

charLength :: C.PGString a => Column a -> Column Int
charLength (Column e) = Column (HPQ.FunExpr "char_length" [e])

-- * Containment operators

-- | 'in_' is designed to be used in prefix form.
--
-- 'in_' @validProducts@ @product@ checks whether @product@ is a valid
-- product.  'in_' @validProducts@ is a function which checks whether
-- a product is a valid product.
in_ :: (Functor f, F.Foldable f) => f (Column a) -> Column a -> Column T.PGBool
in_ fcas (Column a) = Column $ case NEL.nonEmpty (F.toList fcas) of
   Nothing -> HPQ.ConstExpr (HPQ.BoolLit False)
   Just xs -> HPQ.BinExpr HPQ.OpIn a (HPQ.ListExpr (fmap C.unColumn xs))

-- | True if the first argument occurs amongst the rows of the second,
-- false otherwise.
--
-- This operation is equivalent to Postgres's @IN@ operator but, for
-- expediency, is currently implemented using a @LEFT JOIN@.  Please
-- file a bug if this causes any issues in practice.
inQuery :: D.Default EqPP columns columns
        => columns -> Query columns -> Query (Column T.PGBool)
inQuery c q = qj'
  where -- Remove every row that isn't equal to c
        -- Replace the ones that are with '1'
        q' = A.arr (const 1)
             A.<<< keepWhen (c .===)
             A.<<< q

        -- Left join with a query that has a single row
        -- We either get a single row with '1'
        -- or a single row with 'NULL'
        qj :: Query (Column T.PGInt4, Column (C.Nullable T.PGInt4))
        qj = Join.leftJoin (A.arr (const 1))
                           (distinctA q')
                           (uncurry (.==))

        -- Check whether it is 'NULL'
        qj' :: Query (Column T.PGBool)
        qj' = A.arr (Edible.Operators.not
                     . Column.isNull
                     . snd)
              A.<<< qj

-- * JSON operators

-- | Class of Postgres types that represent json values.
--
-- Used to overload functions and operators that work on both 'T.PGJson' and 'T.PGJsonb'.
--
-- Warning: making additional instances of this class can lead to broken code!
class PGIsJson a

instance PGIsJson T.PGJson
instance PGIsJson T.PGJsonb

-- | Class of Postgres types that can be used to index json values.
--
-- Warning: making additional instances of this class can lead to broken code!
class PGJsonIndex a

instance PGJsonIndex T.PGInt4
instance PGJsonIndex T.PGInt8
instance PGJsonIndex T.PGText

-- | Get JSON object field by key.
infixl 8 .->
(.->) :: (PGIsJson a, PGJsonIndex k)
      => Column (C.Nullable a) -- ^
      -> Column k -- ^ key or index
      -> Column (C.Nullable a)
(.->) = C.binOp (HPQ.:->)

-- | Get JSON object field as text.
infixl 8 .->>
(.->>) :: (PGIsJson a, PGJsonIndex k)
       => Column (C.Nullable a) -- ^
       -> Column k -- ^ key or index
       -> Column (C.Nullable T.PGText)
(.->>) = C.binOp (HPQ.:->>)

-- | Get JSON object at specified path.
infixl 8 .#>
(.#>) :: (PGIsJson a)
      => Column (C.Nullable a) -- ^
      -> Column (T.PGArray T.PGText) -- ^ path
      -> Column (C.Nullable a)
(.#>) = C.binOp (HPQ.:#>)

-- | Get JSON object at specified path as text.
infixl 8 .#>>
(.#>>) :: (PGIsJson a)
       => Column (C.Nullable a) -- ^
       -> Column (T.PGArray T.PGText) -- ^ path
       -> Column (C.Nullable T.PGText)
(.#>>) = C.binOp (HPQ.:#>>)

-- | Does the left JSON value contain within it the right value?
infix 4 .@>
(.@>) :: Column T.PGJsonb -> Column T.PGJsonb -> Column T.PGBool
(.@>) = C.binOp (HPQ.:@>)

-- | Is the left JSON value contained within the right value?
infix 4 .<@
(.<@) :: Column T.PGJsonb -> Column T.PGJsonb -> Column T.PGBool
(.<@) = C.binOp (HPQ.:<@)

-- | Does the key/element string exist within the JSON value?
infix 4 .?
(.?) :: Column T.PGJsonb -> Column T.PGText -> Column T.PGBool
(.?) = C.binOp (HPQ.:?)

-- | Do any of these key/element strings exist?
infix 4 .?|
(.?|) :: Column T.PGJsonb -> Column (T.PGArray T.PGText) -> Column T.PGBool
(.?|) = C.binOp (HPQ.:?|)

-- | Do all of these key/element strings exist?
infix 4 .?&
(.?&) :: Column T.PGJsonb -> Column (T.PGArray T.PGText) -> Column T.PGBool
(.?&) = C.binOp (HPQ.:?&)

-- * PGArray Operators

emptyArray :: T.IsSqlType (a :: *) => Column (T.PGArray a)
emptyArray = T.pgArray id []

arrayPrepend :: Column a -> Column (T.PGArray a) -> Column (T.PGArray a)
arrayPrepend (Column e) (Column es) = Column (HPQ.FunExpr "array_prepend" [e, es])

singletonArray :: T.IsSqlType a => Column a -> Column (T.PGArray a)
singletonArray x = arrayPrepend x emptyArray

index :: (C.PGIntegral n) => Column (T.PGArray a) -> Column n -> Column (C.Nullable a)
index (Column a) (Column b) = Column (HPQ.ArrayIndex a b)

-- * Other operators

timestamptzAtTimeZone :: Column T.PGTimestamptz
                      -> Column T.PGText
                      -> Column T.PGTimestamp
timestamptzAtTimeZone = C.binOp HPQ.OpAtTimeZone

-- | Do not use.  Will be deprecated in version 0.6.  Use
-- 'C.unsafeCast' instead.
doubleOfInt :: Column T.PGInt4 -> Column T.PGFloat8
doubleOfInt (Column e) = Column (HPQ.CastExpr "float8" e)

overlap :: Column (T.PGRange a) -> Column (T.PGRange a) -> Column T.PGBool
overlap = C.binOp (HPQ.:&&)

infix 4 .<<
(.<<) :: Column (T.PGRange a) -> Column (T.PGRange a) -> Column T.PGBool
(.<<) = C.binOp (HPQ.:<<)

infix 4 .>>
(.>>) :: Column (T.PGRange a) -> Column (T.PGRange a) -> Column T.PGBool
(.>>) = C.binOp (HPQ.:>>)

infix 4 .&<
(.&<) :: Column (T.PGRange a) -> Column (T.PGRange a) -> Column T.PGBool
(.&<) = C.binOp (HPQ.:&<)

infix 4 .&>
(.&>) :: Column (T.PGRange a) -> Column (T.PGRange a) -> Column T.PGBool
(.&>) = C.binOp (HPQ.:&>)

infix 4 .-|-
(.-|-) :: Column (T.PGRange a) -> Column (T.PGRange a) -> Column T.PGBool
(.-|-) = C.binOp (HPQ.:-|-)
