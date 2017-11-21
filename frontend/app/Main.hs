module Main where


import qualified CircleDescent as C
import qualified SphereDescent as S
import Control.Concurrent
import Control.Monad

main :: IO ()
main = do
    void $ forkIO S.main
    void $ forkIO C.main








