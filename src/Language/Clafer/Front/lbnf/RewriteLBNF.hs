module RewriteLBNF where

-- Haskell module generated by the BNF converter

import AbsLBNF

transGrammar :: Grammar -> Grammar
transGrammar x = case x of
  Grammar defs  -> Grammar $ defs >>= transDef


transDef :: Def -> [Def]
transDef x = case x of
  Rule label cat items  -> [x, Internal (transLabel label) cat (addPos items)]
  _ -> [x]


transLabel :: Label -> Label
transLabel x = case x of
  LabNoP (Id id)  -> LabNoP $ Id $ transIdent id
  _  -> x


transIdent :: Ident -> Ident
transIdent x = case x of
  Ident str  -> Ident $ "Pos" ++ str


addPos is = NTerminal (IdCat (Ident "Span")) : is-- mkInt : mkInt : is

mkInt = NTerminal (IdCat (Ident "Integer"))
