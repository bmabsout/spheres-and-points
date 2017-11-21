module Convenience(module Data.Function,module Convenience) where

import Data.Function
import Debug.Trace

(&.) = flip (.)
infixl 1 &>
(&>) :: Functor f => f a -> (a -> b) -> f b
(&>) = flip (<$>)
{-# INLINE (&>) #-}

traceIt f a = traceShow (f a) a