{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}

module CircleDescent where

import ThreeSharedDrawing
import Linear
import ConstructibleV
import System.Random
import GHCJS.Three
import Control.Monad
import Numeric.AD

import Spline
import Convenience
import GradientDescent


numIcos :: Num a => a
numIcos = 10

main :: IO ()
main = do
  polars <- randPolars
  let spline = convergedSpline polarToCircle polars
  sceneSetup (SceneSetup {
      _spline     = spline
    , _createAll  = createAll
    , _updateAll  = updateAll
    , _divId      = "circleDescent"
    , _width      = 150
    , _height     = 150
    , _zheight    = 11
  })

createAll :: Scene -> [V 1 Double] -> Three [Mesh]
createAll scene startConfig =
  startConfig &> (\angle ->
                    do ico <- makeIco scene
                       angleToCircle angle ico
                       return ico)
              & sequence

updateAll :: [Mesh] -> Double -> [V 1 Double] -> Three ()
updateAll elements time currAngles =
  (zip elements currAngles) `forM_` (\(ico,currAngle) ->
    do angles <- rotation ico
       setRotation angles {eX = time, eY = time} ico
       angleToCircle currAngle ico
  )

polarToCircle :: (Floating a) => V 1 a -> V 2 a
polarToCircle (a :> Nil) = angle a * numIcos / pi & toV

angleToCircle :: V 1 Double -> Mesh -> Three ()
angleToCircle = polarToCircle &. pos &. setPosition
  where pos (x :> y :> Nil) = Vector3 x y 0

-- perfect m = iterate (+dAngle) 0
--             & take m
--   where dAngle = 2*pi / fromIntegral m

randPolars :: IO [V 1 Double]
randPolars = randVecs &> take numIcos &> map (* (2*pi))

