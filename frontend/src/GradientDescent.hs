module GradientDescent(
    makeSpline
    ,gravityCost
    ) where

import Convenience

import Linear
import Linear.V
import Numeric.AD
import Control.Monad
import Control.Monad.State
import System.Random
import Control.Applicative
import qualified Data.Vector as V

import Spline

gravityCost :: (Metric f,Floating b, Foldable t, Eq b, Eq (f b), Functor t) => t (f b) -> b
gravityCost points =
    points
    &> (\p1 -> points &> (\p2 -> if p1 == p2 then 0 else 1 / qd p1 p2)
                      & sum)
    & sum

instance (Random a) => Random (V2 a) where
  random = state random & pure & sequence & runState
  randomR (a,b) = liftA2 (curry randomR) a b &> state & sequence & runState

instance (Enum a) => Enum (V2 a) where
  fromEnum _ = error "no instance"
  toEnum _ = error "no instance"
  enumFromThenTo (V2 x1 y1) (V2 dx dy) (V2 x2 y2) = zipWith V2 (enumFromThenTo x1 dx x2) (enumFromThenTo y1 dy y2)


slowConverge :: (Traversable t, Additive t, Floating a, Ord a) =>
                      (t a -> a) -> (t a -> [t a]) -> t a -> [t a]
slowConverge cost optimizer w =
    zip withCosts (tail withCosts)
    & takeWhile (\((_,c1),(_,c2)) -> abs (c2 - c1) > 0.001)
    &> (\(_, (v,_)) -> v)
  where withCosts = let descending = optimizer w
                    in zip descending (descending &> cost)


-- lerpedDescent w = lerp 0.4 w (conjugateGradientDescent cost w !! 1)

makeSpline :: (Show a, Ord a, Enum a,Floating a, Eq a)
           => ([a] -> a) -> ([a] -> [[a]]) -> [a] -> V.Vector [a]
makeSpline cost optimizer old =
    slowConverge cost optimizer old & V.fromList & traceIt V.length
    -- & zip [0,(1/(converged & length & fromIntegral)) .. 1]
    -- &> (Linear . Splined)
    -- & spline getInterpolant

