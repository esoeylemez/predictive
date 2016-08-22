-- |
-- Copyright:  (c) 2016 Ertugrul Söylemez
-- License:    BSD3
-- Maintainer: Ertugrul Söylemez <esz@posteo.de>
-- Stability:  experimental

module Data.Predictive
    ( -- * Predictive scans
      Predictor(..),
      predictor,
      predictor_,

      -- * Queries
      consistent,
      current,
      lastConsistent,
      pending,

      -- * Applying deltas
      applyLocal,
      applyRemote
    )
    where

import Data.Sequence (Seq, ViewL(..), ViewR(..), (|>), viewl, viewr)
import qualified Data.Sequence as Seq


-- | A predictor tracks information on the current state of type @s@ and
-- deltas of type @d@.  It records a sequence of pending local deltas
-- and the last state known to be consistent on both sides.  As remote
-- deltas arrive they are reconciled with the pending local deltas.

data Predictor d s =
    -- | Warning: If you use the constructor directly, keep in mind that
    -- for efficiency reasons this library operates under the assumption
    -- that the second tuple components of the '_predPending' field are
    -- the predicted states as produced by the corresponding delta.
    Predictor {
      _predAgree   :: d -> d -> Bool,  -- ^ Do the deltas agree?
      _predApply   :: d -> s -> s,     -- ^ Effect of a delta on the state.
      _predLast    :: s,               -- ^ Last consistent state.
      _predPending :: Seq (d, s)       -- ^ Pending local deltas and their resulting states.
    }


-- | Apply the given local delta.  This adds it to the sequence of
-- pending deltas.

applyLocal :: d -> Predictor d s -> Predictor d s
applyLocal ds p = p { _predPending = _predPending p |> (ds, apply ds s') }
    where
    apply = _predApply p

    s' = case viewr (_predPending p) of
           _ :> (_, s') -> s'
           EmptyR       -> _predLast p


-- | Apply the given remote delta.
--
-- If the given delta agrees with the oldest pending local delta, this
-- function removes the latter from the pending sequence and marks the
-- new state as the last consistent state.  If it disagrees, all pending
-- local deltas are removed and the state is reset to the last
-- consistent state before applying the given delta.

applyRemote :: d -> Predictor d s -> Predictor d s
applyRemote ds p =
    case viewl (_predPending p) of
      EmptyL -> p { _predLast = apply ds (_predLast p) }
      (ds', s) :< dss
          | agree ds' ds -> p { _predLast = s, _predPending = dss }
          | otherwise    -> p { _predLast = apply ds (_predLast p), _predPending = mempty }

    where
    Predictor { _predAgree   = agree,
                _predApply   = apply
              } = p


-- | Is the given predictor currently consistent?  Equivalently: Have
-- all local deltas so far been acknowledged by agreeing remote deltas?

consistent :: Predictor d s -> Bool
consistent = Seq.null . _predPending


-- | The current predicted state.  If the predictor is 'consistent',
-- this will agree with 'lastConsistent'.

current :: Predictor d s -> s
current p =
    case viewr (_predPending p) of
      _ :> (_, s) -> s
      EmptyR      -> _predLast p


-- | The last consistent state.  If the predictor is 'consistent', this
-- will agree with 'current'.

lastConsistent :: Predictor d s -> s
lastConsistent = _predLast


-- | Sequence of pending deltas ordered chronologically with the oldest
-- one left together with the effect that delta is predicted to have on
-- the state.  If the predictor is consistent, this function returns the
-- empty sequence.

pending :: Predictor d s -> Seq (d, s)
pending = _predPending


-- | Construct a predictor from the given functions and initial state.

predictor
    :: (d -> d -> Bool)  -- ^ Do the given deltas agree?
    -> (d -> s -> s)     -- ^ Effect of a delta on the state.
    -> s                 -- ^ Initial state.
    -> Predictor d s
predictor agree apply s0 =
    Predictor { _predAgree   = agree,
                _predApply   = apply,
                _predLast    = s0,
                _predPending = mempty
              }


-- | A simplified variant of 'predictor' for cases when deltas agree when
-- they are equal.

predictor_
    :: (Eq d)
    => (d -> s -> s)  -- ^ Effect of a deltas on the state.
    -> s              -- ^ Initial state.
    -> Predictor d s
predictor_ = predictor (==)
