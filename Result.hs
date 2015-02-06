{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module Result where

import qualified Data.Aeson as A
import GHC.Generics
import Data.Text

data Severity = VeryPos | Pos | Neutral | Neg | VeryNeg deriving(Eq, Show, Generic)
instance A.FromJSON Severity
instance A.ToJSON Severity

data ResultKind = Error | Game deriving(Eq, Show, Generic)
instance A.FromJSON ResultKind
instance A.ToJSON ResultKind

data Result = Result 
    { severity :: Severity
    , kind :: ResultKind
    , msgs :: [Text]
    } deriving (Show, Generic)
instance A.FromJSON Result
instance A.ToJSON Result

result :: ResultKind -> Severity -> Text -> Result
result kind sev msg = Result 
                        { severity = sev
                        , kind = kind
                        , msgs = [msg] }

appendMsg :: Text -> Result -> Result
appendMsg msg res = res { msgs = msgs res ++ [msg] }
