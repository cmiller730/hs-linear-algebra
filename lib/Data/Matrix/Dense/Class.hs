-----------------------------------------------------------------------------
-- |
-- Module     : Data.Matrix.Dense.Class
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--

module Data.Matrix.Dense.Class (
    -- * Overloaded dense matrix types
    BaseMatrix( ldaMatrix, isHermMatrix, coerceMatrix ),
    ReadMatrix,
    WriteMatrix,
    
    -- * Overloaded interface for matrices
    module Data.Matrix.Class,
    module Data.Matrix.Class.MMatrix,
    
    -- * Creating matrices
    newMatrix_,
    newMatrix,
    newListMatrix,
    newRowsMatrix,
    newColsMatrix,
    newRowMatrix,
    newColMatrix,

    -- * Special matrices
    newZeroMatrix,
    setZeroMatrix,
    newConstantMatrix,
    setConstantMatrix,
    newIdentityMatrix,
    setIdentityMatrix,
    
    -- * Copying matrices
    newCopyMatrix,
    newCopyMatrix',
    copyMatrix,
    swapMatrix,
    
    -- * Swapping rows and columns
    swapRows,
    swapCols,

    -- * Matrix views
    submatrixView,
    splitRowsAt,
    splitColsAt,

    -- * Row and Column views
    rowViews,
    colViews,
    rowView,
    colView,
    diagView,
    
    -- * Getting diagonals
    getDiag,
    
    -- * Overloaded interface for reading and writing matrix elements
    module Data.Tensor.Class,
    module Data.Tensor.Class.MTensor,

    -- * Matrix operations
    -- ** Unary
    getConjMatrix,
    getScaledMatrix,
    getShiftedMatrix,
    doConjMatrix,
    scaleByMatrix,
    shiftByMatrix,
    
    -- ** Binary
    getAddMatrix,
    getSubMatrix,
    getMulMatrix,
    getDivMatrix,
    addMatrix,
    subMatrix,
    axpyMatrix,
    mulMatrix,
    divMatrix,

    -- * Conversions between mutable and immutable matrices
    freezeMatrix,
    thawMatrix,
    unsafeFreezeMatrix,
    unsafeThawMatrix,
        
    ) where

import Data.Matrix.Dense.Base

import Data.Matrix.Class
import Data.Matrix.Class.MMatrix

import Data.Tensor.Class
import Data.Tensor.Class.MTensor

