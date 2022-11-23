{-# LANGUAGE GADTs #-}
module SRL.AST
  ( module SRL.AST,
    module Common.AST
  ) where

import Common.AST

-- =============
-- An SRL program
-- =============

data SRLProgram where
  SRLProgram :: TypeTab -> AST -> SRLProgram

instance Show SRLProgram where
  show (SRLProgram ttab ast) = showAST ttab ast


-- ===
-- AST
-- ===

type AST = Block
showAST :: TypeTab -> AST -> String
showAST ttab ast = showTypeTab ttab ++ showBlock 0 ast

data Block = Step Step
           | If Exp Block Block Exp
           | Loop Exp Block Block Exp
           | Seq Block Block
showBlock :: Int -> Block -> String
showBlock lvl b = case b of
  Step s         -> indent ++ show s

  If t b1 b2 a   -> indent ++ "if " ++ show t ++ " then\n"
                 ++ showBlock (lvl + 1) b1 ++ "\n"
                 ++ indent ++ "else\n"
                 ++ showBlock (case b2 of If{} -> lvl ; _ -> lvl + 1)  b2 ++ "\n"
                 ++ indent ++ "fi " ++ show a

  Loop t b1 b2 a -> indent ++ "from "  ++ show t ++ " do\n"
                 ++ showBlock (lvl + 1) b1 ++ "\n"
                 ++ indent ++ "loop\n"
                 ++ showBlock (lvl + 1) b2 ++ "\n"
                 ++ indent ++ "until " ++ show a

  Seq b1 b2      -> showBlock lvl b1 ++ "\n"
                 ++ showBlock lvl b2

  where indent = replicate (4 * lvl) ' '
