{-# LANGUAGE TypeFamilies, FlexibleContexts #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Diagrams.TwoD.Shapes
-- Copyright   :  (c) Brent Yorgey 2010
-- License     :  BSD-style (see LICENSE)
-- Maintainer  :  byorgey@cis.upenn.edu
-- Stability   :  experimental
-- Portability :  portable
--
-- Various two-dimensional shapes.
--
-----------------------------------------------------------------------------

module Diagrams.TwoD.Shapes
       ( polygon, polygonPath, polygonVertices
       , square
       , createStar
       ) where

import Graphics.Rendering.Diagrams

import Diagrams.Path
import Diagrams.TwoD.Types
import Diagrams.TwoD.Transform

import qualified Data.Map as M

import Data.Monoid (Any(..))

-- | Create a regular polygon with the given number of sides, with a
--   radius (distance from the center to any vertex) of one, and a
--   vertex at (1,0).
polygon:: (BSpace b ~ R2, Renderable (Path R2) b) => Int -> Diagram b
polygon = stroke . polygonPath

-- | Create a closed, radius-one regular polygonal path with the given
--   number of edges, with a vertex at (1,0).
polygonPath:: Int -> Path R2
polygonPath = close . pathFromVertices . polygonVertices

-- | Generate the vertices of a radius-one regular polygon with the
--   given number of sides, with a vertex at (1,0).
polygonVertices:: Int -> [P2]
polygonVertices n = take n . iterate (rotate angle) $ start
  where start = translateX 1 origin
        angle = 2*pi / fromIntegral n

-- | A sqaure with its center at the origin and sides of length 1,
--   oriented parallel to the axes.
square ::  (BSpace b ~ R2, Renderable (Path R2) b) => Diagram b
square = scale (1/sqrt 2) . rotateBy (1/8) $ polygon 4

-- | Generate a star polygon
--   Formula: (pi*(p - 2q))/p ; p is the first arguement and q is the second arguement
createStar :: (BSpace b ~ R2, Renderable (Path R2) b) => Int -> Int-> Diagram b
createStar p q =  stroke . close $ pathFromVertices $ createStarH origin p q p 0

-- | Create a path to draw a star
--   take staring point(P2) as an arguement; p and q from the star formula;cumulative angle as the third argument; star tracker as the forth arguement
createStarH :: P2 -> Int -> Int -> Int -> Angle -> [P2]
createStarH _ _ _ 0 _ = []
createStarH v@(P r) p q n a = (point : createStarH point p q (n - 1) angle)
          where angle = (a + pi - (pi*(fromIntegral p-2*(fromIntegral q))/fromIntegral p))
                point = translateY (snd r) . translateX (fst r) $ rotate angle (translateY 1 origin)
