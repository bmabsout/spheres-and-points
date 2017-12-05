module Spline(module Spline) where

import Linear
import Convenience
import qualified Data.Vector as V


interpol :: (Additive f, Applicative v,Num (v Double))
         => V.Vector (f (v Double)) -> Double
         -> f (v Double)
interpol l normalized =
    lerp (pure $ i - (fromIntegral floored))
         (l V.! (floored+1))
         (l V.! floored)
  where floored :: Int
        floored = floor i 
        i = normalized * (fromIntegral $ V.length l - 2)

reduceSpline :: (Additive f, Applicative v,Num (v Double))
             => Int -> V.Vector (f (v Double))
             -> V.Vector (f (v Double))
reduceSpline numFrames spline =
    [0, 1/(fromIntegral numFrames) .. 1]
    &> (\x -> x**2)
    & V.fromList
    &> interpol spline
