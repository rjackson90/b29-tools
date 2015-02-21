{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Weather 
( WeatherInZone(..)
, defaultWeatherInZone
, BadWeatherImpact(..)
, defaultBadWeatherImpact
) where

import GHC.Generics
import qualified Data.Aeson as A
import Control.Monad.Writer

import State
import Result
import Charts
import Dice

data WeatherInZone = WeatherInZone
    { weather :: Weather
    , altitude :: Altitude
    , fuel :: Int
    , direction :: Direction
    } deriving(Show, Generic)
instance A.FromJSON WeatherInZone
instance A.ToJSON WeatherInZone

defaultWeatherInZone :: WeatherInZone
defaultWeatherInZone = WeatherInZone Good Low 32 Outbound

instance Chart WeatherInZone where
    get _ = ChartDescriptor "4-2" "Weather in Zone" instructions "/#/charts/4-2"
        where instructions = "The first chart to roll on when doing a Weather Check. Roll 2d6."

    post state dice
        | mod <= 2 = do
            tell [Result Game Pos "Good weather"]
            jet_stream state { weather = Good }
        | mod >= 3 && mod <= 8 = do
            tell [Result Game VeryPos "Good weather"]
            return state { weather = Good }
        | mod == 9 = do
            tell [Result Game Neutral "Poor weather"]
            return state { weather = Poor }
        | mod == 10 = do
            tell [Result Game Neg "Poor weather"]
            jet_stream state { weather = Poor }
        | mod == 11 = do
            tell [Result Game VeryNeg "Bad Weather"]
            tell [Result Game VeryNeg "Roll on Table 4-3 to determine the impact of flying through\
                                      \ bad weather"]
            jet_stream state { weather = Bad }
        | mod >= 12 = do
            tell [Result Game VeryNeg "Bad Weather"]
            tell [Result Game VeryNeg "Roll on Table 4-3 to determine the impact of flying through\
                                      \ bad weather"]
            return state { weather = Bad }
        
        where
            modifiers = [\s -> if weather s == Poor 
                                   then (+) 1 
                                   else (+) 0
                        ,\s -> if weather s == Bad 
                                   then (+) 2
                                   else (+) 0
                        ,\s -> if altitude s == High 
                                   then (subtract) 1
                                   else (+) 0 ]
            
            mod = modify modifiers state dice

            jet_stream :: WeatherInZone -> ResultWriter WeatherInZone
            jet_stream s = if altitude s == High
                                then case direction s of
                                    Outbound -> writer ( s { fuel = fuel s - 1 }, 
                                                [ Result Game Neg "Encountered jet stream"
                                                , Result Game Neg "Lost one fuel box"] )
                                    
                                    Inbound -> writer ( s { fuel = fuel s + 1 },
                                               [ Result Game Pos "Encountered jet stream"
                                               , Result Game Pos "Gained one fuel box"] )
                                else writer ( s, [Result Game Neutral "No effect from jet stream"])



data BadWeatherImpact = BadWeatherImpact
    { form :: Formation
    , radarBroken :: Bool
    , radarOperator :: Crew
    , fuelSpent :: Bool
    } deriving(Show, Generic)
instance A.FromJSON BadWeatherImpact
instance A.ToJSON BadWeatherImpact

defaultBadWeatherImpact :: BadWeatherImpact
defaultBadWeatherImpact = BadWeatherImpact In False Healthy False

instance Chart BadWeatherImpact where
    get _ = ChartDescriptor "4-3" "Impact of Bad Weather" instructions "/#/charts/4-3"
        where instructions = "Roll on this chart if the result from 4-2 was 'Bad'. Roll 1d6"

    post state dice 
        | mod <= 4 = do
            tell [Result Game Pos "Safe passage; continue with no impact"]
            return state
        | mod == 5 = do
            formationDisrupted state
            collisionRisk state
        | mod == 6 = do 
            formationDisrupted state
            collisionRisk state
            stormDamage state
        | mod >= 7 = do
            formationDisrupted state
            collisionRisk state
            stormDamage state
            damagedElectricalSystem state

        where
            modifiers = [ \s -> if radarOperator s == SevereWound || radarOperator s == Dead
                                    then (+1)
                                    else (+0)
                        , \s -> if radarBroken s
                                    then (+1)
                                    else (+0)
                        , \s -> if fuelSpent s
                                    then (subtract 1)
                                    else (+0)]

            mod = modify modifiers state dice
            
            formationDisrupted :: BadWeatherImpact -> ResultWriter BadWeatherImpact
            formationDisrupted s = if form s == In
                                        then writer ( s { form = Disrupted }
                                                    , [Result Game Neg "Formation Disrupted"])
                                        else writer ( s
                                                    , [])

            collisionRisk :: BadWeatherImpact -> ResultWriter BadWeatherImpact
            collisionRisk s = 
                writer ( s, [Result Game Neg "Roll on chart 4-3-1 for collision risk"] )

            stormDamage :: BadWeatherImpact -> ResultWriter BadWeatherImpact
            stormDamage s = 
                writer (s, [Result Game Neg "Storm damage to the B-29. Roll once on \
                    \Table 7-9 'Cockpit Instruments' and twice on Table 7-5 'Wings' \
                    \(once for each wing)"])

            damagedElectricalSystem :: BadWeatherImpact -> ResultWriter BadWeatherImpact
            damagedElectricalSystem s =
                writer (s, [Result Game VeryNeg "Lightning strike damages B-29's electrical \
                    \system. Electrical system takes 1 hit. For details see Table 7-10, roll 11."])
