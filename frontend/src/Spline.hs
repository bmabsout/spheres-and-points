module Spline(module Spline) where

import Linear
import Convenience
import qualified Data.Vector as V


interpol :: (Additive f)
         => V.Vector (f Double) -> Double
         -> f Double
interpol l normalized =
    lerp (i - (fromIntegral floored))
         (l V.! (floored+1))
         (l V.! floored)
  where floored :: Int
        floored = floor i 
        i = normalized * (fromIntegral $ V.length l - 2)

reduceSpline :: Additive f
             => Int -> V.Vector (f Double)
             -> V.Vector (f Double)
reduceSpline numFrames spline =
    [0, 1/(fromIntegral numFrames) .. 1]
    &> (\x -> x**2)
    & V.fromList
    &> interpol spline
