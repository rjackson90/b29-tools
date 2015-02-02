{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module State
( Altitude (High, Medium, Low)
, Weather (Good, Poor, Bad)
, Direction (Inbound, Outbound)
, Fuel
, GameState (GameState, altitude, weather, direction, fuel)
, Dice (val)
, d6
, modified_die
) where

import Data.Aeson
import GHC.Generics

data Altitude = High | Medium | Low deriving (Eq, Show, Generic)
instance FromJSON Altitude
instance ToJSON Altitude

data Weather = Good | Poor | Bad deriving (Eq, Show, Generic)
instance FromJSON Weather
instance ToJSON Weather

data Direction = Inbound | Outbound deriving (Eq, Show, Generic)
instance FromJSON Direction
instance ToJSON Direction

type Fuel = Int

data GameState = GameState
    { altitude  :: Altitude
    , weather   :: Weather
    , direction :: Direction
    , fuel      :: Fuel
    } deriving (Show, Generic)

instance FromJSON GameState
instance ToJSON GameState

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
