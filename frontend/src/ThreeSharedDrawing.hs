{-# LANGUAGE JavaScriptFFI #-}
{-# LANGUAGE NamedFieldPuns #-}

module ThreeSharedDrawing where

import GHCJS.Three

import GHCJS.DOM.NonElementParentNode (getElementById)
import GHCJS.DOM
import GHCJS.DOM.Document
import GHCJS.DOM.HTMLDivElement
import GHCJS.DOM.JSFFI.Generated.Element
import GHCJS.DOM.Node
import GHCJS.DOM.Types
import Data.Maybe (fromJust)
import Data.IORef
import Linear
import qualified Data.Vector as V

import GradientDescent
import Spline
import Convenience

data SceneSetup = SceneSetup {
    _spline     :: V.Vector [Double]
  , _createAll  :: Scene -> [Double] -> Three [Mesh]
  , _updateAll  :: [Mesh] -> Double -> [Double] -> Three ()
  , _divId      :: JSString
  , _width      :: Double
  , _height     :: Double
  , _zheight    :: Double
}


sceneSetup :: SceneSetup -> Three ()
sceneSetup (SceneSetup spline createAll updateAll divId width height zheight) = do
  scene <- mkScene
  camera <- mkPerspectiveCamera 45 1 0.1 1000
  renderer <- mkWebGLRenderer [ROAlpha True, ROAntialias True]
  setClearColor 0 0 renderer
  setSize width height renderer
  glElem <- domElement renderer
  cp <- position camera
  setPosition cp {v3z = zheight} camera

  light <- mkDirectionalLight 0xffffff 0.7
  setPosition (Vector3 0 1 1) light
  add (toGLNode light) (toGLNode scene)

  ambient <- mkAmbientLight 0xffffaa
  add (toGLNode ambient) (toGLNode scene)

  -- setup the DOM document and append the gl canvas to 'body'
  document <- currentDocumentUnchecked
  Just convergeDiv <- getElementById document divId
  appendChild (uncheckedCastTo HTMLDivElement convergeDiv) (fromJust glElem)

  let startPoss = interpol spline 0
  elements <- createAll scene startPoss

  timeRef <- newIORef 0
  -- posRef <- newIORef startPoss

  runThree $ do
    modifyIORef timeRef (+0.01)
    time <- readIORef timeRef
    interpolant <- toScreenPercent (fromJust glElem)

    let currAngles = interpol spline ((1-interpolant)^^2)
    
    updateAll elements time currAngles

    render scene camera renderer


makeIco :: Scene -> Three Mesh
makeIco scene = do
  geo <- mkIcosahedronGeometry 1 0
  mat <- mkMeshPhongMaterial
  c <- mkColor 0.2 0.3 0.5
  setColor c mat
  ico <- mkMesh geo mat
  add (toGLNode ico) (toGLNode scene)
  return ico

foreign import javascript unsafe
    "$1.getBoundingClientRect().top/Math.max(document.documentElement.clientHeight, window.innerHeight || 0)"
    jsToScreenPercent :: Element -> IO Double

toScreenPercent :: Element -> IO Double
toScreenPercent e = jsToScreenPercent e &> (\v -> max 0 (min 1 v))
