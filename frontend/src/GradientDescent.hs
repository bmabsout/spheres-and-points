{-# LANGUAGE TypeInType #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}

module GradientDescent(convergedSpline, randVecs) where


import Convenience

import Linear
import Linear.V
import Numeric.AD
import Control.Monad
import Control.Monad.State
import System.Random
import Control.Applicative
import Data.Functor.Compose
import qualified Data.Vector as V

import Spline

gravityCost :: ( Metric v
               , Floating b
               , Eq (v b)
               , Metric t
               , Foldable t
               , Functor t)
            => t (v b) -> b
gravityCost points = 
    points
      & fmap (\p1 -> 
            points
              & fmap (gravity p1)
              & sum)
      & sum
  where
    gravity p1 p2 = 
      if p1 == p2 
      then 0
      else (1 / qd p1 p2)


cost :: ( Metric v
         , Floating a
         , Eq (v a)
         , Metric t
         , Foldable t
         , Functor t)
     => (v2 a -> v a)
     -> (Compose t v2 a)
     -> a
cost toPoints (Compose list) =
  list &> toPoints & gravityCost

instance (Random a,Dim n) => Random (V n a) where
  random = state random & pure & sequence & runState
  randomR (a,b) = liftA2 (curry randomR) a b &> state & sequence & runState

randVecs :: (Random a,Floating a,Dim n) => IO [V n a]
randVecs = do
    let g = mkStdGen 400
    return (randomRs (0,1) g)

convergedSpline :: ( Floating a
                   , Dim n
                   , Dim m
                   , Ord a)
                => (forall b . Floating b => V n b -> V m b)
                -> [V n a]
                -> V.Vector [V n a]
convergedSpline toPoints old =
    zip withCosts (tail withCosts)
    & takeWhile (\((_,c1),(_,c2)) -> abs (c2 - c1) > 0.001)
    &> (\((v,_), _) -> v)
    & V.fromList
  where withCosts =
          let descending = conjugateGradientDescent (cost toPoints) (Compose old)
                             &> (\(Compose x) -> x)
          in zip descending (descending &> Compose &. cost toPoints)

