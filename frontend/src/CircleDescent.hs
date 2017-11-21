{-# LANGUAGE OverloadedStrings #-}

module CircleDescent where

import ThreeSharedDrawing
import Linear
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
  let spline = polars & take numIcos & makeSpline cost (conjugateGradientDescent cost)
  sceneSetup (SceneSetup {
      _spline     = spline
    , _createAll  = createAll
    , _updateAll  = updateAll
    , _divId      = "circleDescent"
    , _width      = 150
    , _height     = 150
    , _zheight    = 11
  })

cost :: (Eq a, Floating a) => [a] -> a
cost l = l &> polarToCircle & gravityCost

createAll :: Scene -> [Double] -> Three [Mesh]
createAll scene startConfig =
  startConfig &> (\angle ->
                    do ico <- makeIco scene
                       angleToCircle angle ico
                       return ico)
              & sequence

updateAll :: [Mesh] -> Double -> [Double] -> Three ()
updateAll elements time currAngles =
  (zip elements currAngles) `forM_` (\(ico,currAngle) ->
    do angles <- rotation ico
       setRotation angles {eX = time, eY = time} ico
       angleToCircle currAngle ico
  )

polarToCircle :: (Floating a) => a -> V2 a
polarToCircle = angle &. (*(numIcos/pi))

angleToCircle :: Double -> Mesh -> Three ()
angleToCircle = polarToCircle &. pos &. setPosition
  where pos (V2 x y) = Vector3 x y 0

-- perfect m = iterate (+dAngle) 0
--             & take m
--   where dAngle = 2*pi / fromIntegral m

randPolars :: IO [Double]
randPolars = do
    -- g <- newStdGen
    let polars = randomRs (-pi,pi) (mkStdGen 653)
    return (polars & take numIcos)

