{-# LANGUAGE DeriveGeneric #-}

module Charts (
    Chart(get, post)
    , ChartDescriptor(..)
)where

import GHC.Generics
import Data.Aeson
import Data.Text

import State
import Dice
import qualified Result as R

data ChartDescriptor = ChartDescriptor
    { number :: Text
    , name :: Text
    , instructions :: Text
    , link :: Text} deriving(Show, Generic)
instance FromJSON ChartDescriptor
instance ToJSON ChartDescriptor

class (ToJSON a, FromJSON a) => Chart a where
    get :: a -> ChartDescriptor
    post :: a -> Dice -> R.ResultWriter a
