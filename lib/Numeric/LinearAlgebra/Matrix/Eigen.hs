-----------------------------------------------------------------------------
-- |
-- Module     : Numeric.LinearAlgebra.Matrix.Eigen
-- Copyright  : Copyright (c) 2010, Patrick Perry <patperry@gmail.com>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@gmail.com>
-- Stability  : experimental
--
-- Eigenvalue decompositions.
--
module Numeric.LinearAlgebra.Matrix.Eigen (
    hermEigen,
    hermEigenvalues,
    hermEigenTo,
    hermEigenvaluesTo,
    ) where

import Control.Monad.ST( ST, runST, unsafeIOToST )
import Foreign( allocaArray, nullPtr )
import Text.Printf( printf )

import Foreign.LAPACK( LAPACK, EigJob(..), EigRange(..) )
import qualified Foreign.LAPACK as LAPACK

import Numeric.LinearAlgebra.Types( Herm(..) )
import Numeric.LinearAlgebra.Matrix.Base( Matrix )
import Numeric.LinearAlgebra.Matrix.STBase( STMatrix )
import qualified Numeric.LinearAlgebra.Matrix.Base as M
import qualified Numeric.LinearAlgebra.Matrix.STBase as M
import Numeric.LinearAlgebra.Vector( Vector, STVector )
import qualified Numeric.LinearAlgebra.Vector as V

-- | Compute the eigenvalues and eigenvectors of a Hermitian matrix.
-- Return the eigenvalues are in ascending order in the result vector; 
-- store the corresponding eigenvectors are in the columns of the result
-- matrix.
hermEigen :: (LAPACK e) => Herm Matrix e -> (Vector Double, Matrix e)
hermEigen (Herm uplo a) = runST $ do
    ma <- M.newCopy a
    mw <- V.new_ n
    mz <- M.new_ (n,n)
    hermEigenTo (Herm uplo ma) mw mz
    w <- V.unsafeFreeze mw
    z <- M.unsafeFreeze mz
    return (w,z)
  where
    (_,n) = M.dim a

-- | Return the eigenvalues of a Hermitian matrix in ascending order.
hermEigenvalues :: (LAPACK e) => Herm Matrix e -> Vector Double
hermEigenvalues (Herm uplo a) = V.create $ do
    ma <- M.newCopy a
    w <- V.new_ n
    hermEigenvaluesTo (Herm uplo ma) w
    return w
  where
    (_,n) = M.dim a

-- | Compute and copy the eigenvalues and eigenvectors of a mutable
-- Hermitian matrix.  This destroys the original Hermitian matrix.
hermEigenTo :: (LAPACK e)
                  => Herm (STMatrix s) e
                  -> STVector s Double
                  -> STMatrix s e
                  -> ST s ()
hermEigenTo (Herm uplo a) w z
    | ma /= na =  error $
        printf ("hermEigenTo"
                ++ " (Herm _ <matrix with dim (%d,%d)>): nonsquare matrix"
               ) ma na
    | (not . and) [ (ma,na) == (n,n)
                  , nw == n
                  , (mz,nz) == (n,n)
                  ] = error $
        printf ("hermEigenTo"
                ++ " (Herm _ <matrix with dim (%d,%d)>)"
                ++ " <vector with dim %d>:"
                ++ " <matrix with dim (%d,%d)>"
                ++ " dimension mismatch")
               ma na nw mz nz
    | otherwise =
        unsafeIOToST $
            M.unsafeWith a $ \pa lda ->
            V.unsafeWith w $ \pw ->
            M.unsafeWith z $ \pz ldz ->
            allocaArray (2*n) $ \psuppz -> do
                _m <- LAPACK.heevr jobz range uplo n pa lda abstol pw pz ldz
                                   psuppz
                return ()
    
  where
    (ma,na) = M.dim a
    (mz,nz) = M.dim z
    nw = V.dim w
    n = na
    jobz = EigVectors
    range = AllEigs
    abstol = 0

-- | Compute and copy the eigenvalues of a mutable Hermitian matrix.  This
-- destroys the original Hermitian matrix.
hermEigenvaluesTo :: (LAPACK e)
                        => Herm (STMatrix s) e
                        -> STVector s Double
                        -> ST s ()
hermEigenvaluesTo (Herm uplo a) w
    | ma /= na =  error $
        printf ("hermEigenvaluesTo"
                ++ " (Herm _ <matrix with dim (%d,%d)>): nonsquare matrix"
               ) ma na
    | (not . and) [ (ma,na) == (n,n)
                  , nw == n
                  ] = error $
        printf ("hermEigenvaluesTo"
                ++ " (Herm _ <matrix with dim (%d,%d)>)"
                ++ " <vector with dim %d>: dimension mismatch")
               ma na nw
    | otherwise =
        unsafeIOToST $
            M.unsafeWith a $ \pa lda ->
            V.unsafeWith w $ \pw -> do
                _m <- LAPACK.heevr jobz range uplo n pa lda abstol pw pz ldz
                                   psuppz
                return ()
    
  where
    (ma,na) = M.dim a
    nw = V.dim w
    n = na
    jobz = NoEigVectors
    range = AllEigs
    abstol = 0
    pz = nullPtr
    ldz = 1
    psuppz = nullPtr