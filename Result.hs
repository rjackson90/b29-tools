{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module Result where

import qualified Data.Aeson as A
import GHC.Generics
import Data.Text
import Control.Monad.Writer.Lazy
import Data.Functor.Identity

data Severity = VeryPos | Pos | Neutral | Neg | VeryNeg deriving(Eq, Show, Generic, Bounded, Enum)
instance A.FromJSON Severity
instance A.ToJSON Severity

data ResultKind = Error | Game deriving(Eq, Show, Generic)
instance A.FromJSON ResultKind
instance A.ToJSON ResultKind

data Result = Result 
    { kind :: ResultKind
    , severity :: Severity
    , msg :: Text
    } deriving (Show, Generic)
instance A.FromJSON Result
instance A.ToJSON Result

type ResultWriter = WriterT [Result] Identity
