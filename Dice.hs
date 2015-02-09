{-# LANGUAGE DeriveGeneric #-}

module Dice 
    ( d6
    , modified_die
    , modify
    , Dice) where

import Data.Aeson
import GHC.Generics

data Dice = Dice { val :: Int }
    deriving (Eq, Ord, Show, Generic)
instance FromJSON Dice
instance ToJSON Dice

d6 :: Int -> Int-> Maybe Dice
d6 dice_count value
    | value >= dice_count && value <= 6 * dice_count = Just (Dice value)
    | otherwise = Nothing

modified_die :: Int -> Dice
modified_die num = Dice { val = num }

modify :: [( a -> (Int -> Int) )] -> a -> Dice -> Int
modify mods state dice = foldr (\x acc -> x state $ acc) (val dice) mods
