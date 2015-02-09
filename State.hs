{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module State where

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

data Formation = In | Disrupted | Out deriving (Eq, Show, Generic)
instance FromJSON Formation
instance ToJSON Formation

type Fuel = Int

data Crew = Healthy | LightWound | SevereWound | Dead | Absent deriving (Eq, Show, Generic)
instance FromJSON Crew
instance ToJSON Crew

