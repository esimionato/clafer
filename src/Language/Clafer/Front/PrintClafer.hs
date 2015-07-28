{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module Language.Clafer.Front.PrintClafer where

-- pretty-printer generated by the BNF converter

import Language.Clafer.Front.AbsClafer
import Data.Char
import Prelude hiding (exp, init)

-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print PosInteger where
  prt _ (PosInteger (_,i)) = doc (showString ( i))


instance Print PosDouble where
  prt _ (PosDouble (_,i)) = doc (showString ( i))


instance Print PosReal where
  prt _ (PosReal (_,i)) = doc (showString ( i))


instance Print PosString where
  prt _ (PosString (_,i)) = doc (showString ( i))


instance Print PosIdent where
  prt _ (PosIdent (_,i)) = doc (showString ( i))



instance Print Module where
  prt i e = case e of
    Module _ declarations -> prPrec i 0 (concatD [prt 0 declarations])

instance Print Declaration where
  prt i e = case e of
    EnumDecl _ posident enumids -> prPrec i 0 (concatD [doc (showString "enum"), prt 0 posident, doc (showString "="), prt 0 enumids])
    ElementDecl _ element -> prPrec i 0 (concatD [prt 0 element])
  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x, prt 0 xs])

instance Print Clafer where
  prt i e = case e of
    Clafer _ abstract gcard posident super reference card init elements -> prPrec i 0 (concatD [prt 0 abstract, prt 0 gcard, prt 0 posident, prt 0 super, prt 0 reference, prt 0 card, prt 0 init, prt 0 elements])

instance Print Constraint where
  prt i e = case e of
    Constraint _ exps -> prPrec i 0 (concatD [doc (showString "["), prt 0 exps, doc (showString "]")])

instance Print Assertion where
  prt i e = case e of
    Assertion _ exps -> prPrec i 0 (concatD [doc (showString "assert"), doc (showString "["), prt 0 exps, doc (showString "]")])

instance Print Goal where
  prt i e = case e of
    Goal _ exps -> prPrec i 0 (concatD [doc (showString "<<"), prt 0 exps, doc (showString ">>")])

instance Print Abstract where
  prt i e = case e of
    AbstractEmpty _ -> prPrec i 0 (concatD [])
    Abstract _ -> prPrec i 0 (concatD [doc (showString "abstract")])

instance Print Elements where
  prt i e = case e of
    ElementsEmpty _ -> prPrec i 0 (concatD [])
    ElementsList _ elements -> prPrec i 0 (concatD [doc (showString "{"), prt 0 elements, doc (showString "}")])

instance Print Element where
  prt i e = case e of
    Subclafer _ clafer -> prPrec i 0 (concatD [prt 0 clafer])
    ClaferUse _ name card elements -> prPrec i 0 (concatD [doc (showString "`"), prt 0 name, prt 0 card, prt 0 elements])
    Subconstraint _ constraint -> prPrec i 0 (concatD [prt 0 constraint])
    Subgoal _ goal -> prPrec i 0 (concatD [prt 0 goal])
    SubAssertion _ assertion -> prPrec i 0 (concatD [prt 0 assertion])
  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x, prt 0 xs])

instance Print Super where
  prt i e = case e of
    SuperEmpty _ -> prPrec i 0 (concatD [])
    SuperSome _ exp18 -> prPrec i 0 (concatD [doc (showString ":"), prt 18 exp18])

instance Print Reference where
  prt i e = case e of
    ReferenceEmpty _ -> prPrec i 0 (concatD [])
    ReferenceSet _ exp15 -> prPrec i 0 (concatD [doc (showString "->"), prt 15 exp15])
    ReferenceBag _ exp15 -> prPrec i 0 (concatD [doc (showString "->>"), prt 15 exp15])

instance Print Init where
  prt i e = case e of
    InitEmpty _ -> prPrec i 0 (concatD [])
    InitSome _ inithow exp -> prPrec i 0 (concatD [prt 0 inithow, prt 0 exp])

instance Print InitHow where
  prt i e = case e of
    InitConstant _ -> prPrec i 0 (concatD [doc (showString "=")])
    InitDefault _ -> prPrec i 0 (concatD [doc (showString ":=")])

instance Print GCard where
  prt i e = case e of
    GCardEmpty _ -> prPrec i 0 (concatD [])
    GCardXor _ -> prPrec i 0 (concatD [doc (showString "xor")])
    GCardOr _ -> prPrec i 0 (concatD [doc (showString "or")])
    GCardMux _ -> prPrec i 0 (concatD [doc (showString "mux")])
    GCardOpt _ -> prPrec i 0 (concatD [doc (showString "opt")])
    GCardInterval _ ncard -> prPrec i 0 (concatD [prt 0 ncard])

instance Print Card where
  prt i e = case e of
    CardEmpty _ -> prPrec i 0 (concatD [])
    CardLone _ -> prPrec i 0 (concatD [doc (showString "?")])
    CardSome _ -> prPrec i 0 (concatD [doc (showString "+")])
    CardAny _ -> prPrec i 0 (concatD [doc (showString "*")])
    CardNum _ posinteger -> prPrec i 0 (concatD [prt 0 posinteger])
    CardInterval _ ncard -> prPrec i 0 (concatD [prt 0 ncard])

instance Print NCard where
  prt i e = case e of
    NCard _ posinteger exinteger -> prPrec i 0 (concatD [prt 0 posinteger, doc (showString ".."), prt 0 exinteger])

instance Print ExInteger where
  prt i e = case e of
    ExIntegerAst _ -> prPrec i 0 (concatD [doc (showString "*")])
    ExIntegerNum _ posinteger -> prPrec i 0 (concatD [prt 0 posinteger])

instance Print Name where
  prt i e = case e of
    Path _ modids -> prPrec i 0 (concatD [prt 0 modids])

instance Print Exp where
  prt i e = case e of
    EDeclAllDisj _ decl exp -> prPrec i 0 (concatD [doc (showString "all"), doc (showString "disj"), prt 0 decl, doc (showString "|"), prt 0 exp])
    EDeclAll _ decl exp -> prPrec i 0 (concatD [doc (showString "all"), prt 0 decl, doc (showString "|"), prt 0 exp])
    EDeclQuantDisj _ quant decl exp -> prPrec i 0 (concatD [prt 0 quant, doc (showString "disj"), prt 0 decl, doc (showString "|"), prt 0 exp])
    EDeclQuant _ quant decl exp -> prPrec i 0 (concatD [prt 0 quant, prt 0 decl, doc (showString "|"), prt 0 exp])
    EGMax _ exp2 -> prPrec i 1 (concatD [doc (showString "max"), prt 2 exp2])
    EGMin _ exp2 -> prPrec i 1 (concatD [doc (showString "min"), prt 2 exp2])
    EIff _ exp1 exp2 -> prPrec i 1 (concatD [prt 1 exp1, doc (showString "<=>"), prt 2 exp2])
    EImplies _ exp2 exp3 -> prPrec i 2 (concatD [prt 2 exp2, doc (showString "=>"), prt 3 exp3])
    EOr _ exp3 exp4 -> prPrec i 3 (concatD [prt 3 exp3, doc (showString "||"), prt 4 exp4])
    EXor _ exp4 exp5 -> prPrec i 4 (concatD [prt 4 exp4, doc (showString "xor"), prt 5 exp5])
    EAnd _ exp5 exp6 -> prPrec i 5 (concatD [prt 5 exp5, doc (showString "&&"), prt 6 exp6])
    ENeg _ exp7 -> prPrec i 6 (concatD [doc (showString "!"), prt 7 exp7])
    ELt _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString "<"), prt 8 exp8])
    EGt _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString ">"), prt 8 exp8])
    EEq _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString "="), prt 8 exp8])
    ELte _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString "<="), prt 8 exp8])
    EGte _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString ">="), prt 8 exp8])
    ENeq _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString "!="), prt 8 exp8])
    EIn _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString "in"), prt 8 exp8])
    ENin _ exp7 exp8 -> prPrec i 7 (concatD [prt 7 exp7, doc (showString "not"), doc (showString "in"), prt 8 exp8])
    EQuantExp _ quant exp12 -> prPrec i 8 (concatD [prt 0 quant, prt 12 exp12])
    EAdd _ exp9 exp10 -> prPrec i 9 (concatD [prt 9 exp9, doc (showString "+"), prt 10 exp10])
    ESub _ exp9 exp10 -> prPrec i 9 (concatD [prt 9 exp9, doc (showString "-"), prt 10 exp10])
    EMul _ exp10 exp11 -> prPrec i 10 (concatD [prt 10 exp10, doc (showString "*"), prt 11 exp11])
    EDiv _ exp10 exp11 -> prPrec i 10 (concatD [prt 10 exp10, doc (showString "/"), prt 11 exp11])
    ERem _ exp10 exp11 -> prPrec i 10 (concatD [prt 10 exp10, doc (showString "%"), prt 11 exp11])
    ESum _ exp12 -> prPrec i 11 (concatD [doc (showString "sum"), prt 12 exp12])
    EProd _ exp12 -> prPrec i 11 (concatD [doc (showString "product"), prt 12 exp12])
    ECard _ exp12 -> prPrec i 11 (concatD [doc (showString "#"), prt 12 exp12])
    EMinExp _ exp12 -> prPrec i 11 (concatD [doc (showString "-"), prt 12 exp12])
    EImpliesElse _ exp120 exp12 exp13 -> prPrec i 12 (concatD [doc (showString "if"), prt 12 exp120, doc (showString "then"), prt 12 exp12, doc (showString "else"), prt 13 exp13])
    EDomain _ exp13 exp14 -> prPrec i 13 (concatD [prt 13 exp13, doc (showString "<:"), prt 14 exp14])
    ERange _ exp14 exp15 -> prPrec i 14 (concatD [prt 14 exp14, doc (showString ":>"), prt 15 exp15])
    EUnion _ exp15 exp16 -> prPrec i 15 (concatD [prt 15 exp15, doc (showString "++"), prt 16 exp16])
    EUnionCom _ exp15 exp16 -> prPrec i 15 (concatD [prt 15 exp15, doc (showString ","), prt 16 exp16])
    EDifference _ exp16 exp17 -> prPrec i 16 (concatD [prt 16 exp16, doc (showString "--"), prt 17 exp17])
    EIntersection _ exp17 exp18 -> prPrec i 17 (concatD [prt 17 exp17, doc (showString "**"), prt 18 exp18])
    EJoin _ exp18 exp19 -> prPrec i 18 (concatD [prt 18 exp18, doc (showString "."), prt 19 exp19])
    ClaferId _ name -> prPrec i 19 (concatD [prt 0 name])
    EInt _ posinteger -> prPrec i 19 (concatD [prt 0 posinteger])
    EDouble _ posdouble -> prPrec i 19 (concatD [prt 0 posdouble])
    EReal _ posreal -> prPrec i 19 (concatD [prt 0 posreal])
    EStr _ posstring -> prPrec i 19 (concatD [prt 0 posstring])
  prtList es = case es of
   [] -> (concatD [])
   x:xs -> (concatD [prt 0 x, prt 0 xs])

instance Print Decl where
  prt i e = case e of
    Decl _ locids exp13 -> prPrec i 0 (concatD [prt 0 locids, doc (showString ":"), prt 13 exp13])

instance Print Quant where
  prt i e = case e of
    QuantNo _ -> prPrec i 0 (concatD [doc (showString "no")])
    QuantNot _ -> prPrec i 0 (concatD [doc (showString "not")])
    QuantLone _ -> prPrec i 0 (concatD [doc (showString "lone")])
    QuantOne _ -> prPrec i 0 (concatD [doc (showString "one")])
    QuantSome _ -> prPrec i 0 (concatD [doc (showString "some")])

instance Print EnumId where
  prt i e = case e of
    EnumIdIdent _ posident -> prPrec i 0 (concatD [prt 0 posident])
  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x, doc (showString "|"), prt 0 xs])

instance Print ModId where
  prt i e = case e of
    ModIdIdent _ posident -> prPrec i 0 (concatD [prt 0 posident])
  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x, doc (showString "\\"), prt 0 xs])

instance Print LocId where
  prt i e = case e of
    LocIdIdent _ posident -> prPrec i 0 (concatD [prt 0 posident])
  prtList es = case es of
   [x] -> (concatD [prt 0 x])
   x:xs -> (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
