{-# LANGUAGE OverloadedStrings #-}
module Charts 
( weather_in_zone 
) where

import State
import Result

weather_in_zone :: GameState -> Dice -> (GameState, Result)
weather_in_zone state dice   
    | mod <= 2              = jet_stream state { weather = Good } $
                              result Game Pos "Good weather"
    | mod >= 3 && mod <= 8  = ( state { weather = Good }
                              , result Game VeryPos "Good weather")
    | mod == 9              = ( state { weather = Poor }
                              , result Game Neutral "Poor weather")
    | mod == 10             = jet_stream state { weather = Poor } $
                              result Game Neg "Poor weather"
    | mod == 11             = jet_stream state { weather = Bad } $
                              appendMsg "ll on Table 4-3 for impact of bad weather" $
                              result Game VeryNeg "Bad weather"
    | mod >= 12             = ( state { weather = Bad }
                              , appendMsg "ll on Table 4-3 for impact of bad weather" $
                                result Game Neg "Bad weather" )
    where
        modifiers = [\d -> if weather state == Poor 
                               then modified_die $ val d + 1 
                               else d
                    ,\d -> if weather state == Bad 
                               then modified_die $ val d + 2
                               else d
                    ,\d -> if altitude state == High 
                               then modified_die $ val d - 1
                               else d ]
        
        mod = val $ foldr ($) dice modifiers

        jet_stream :: GameState -> Result -> (GameState, Result)
        jet_stream st res = if altitude st == High 
                                then case direction st of
                                    Outbound    -> ( st { fuel = fuel st - 1 }
                                                   , appendMsg "Encountered jet stream" $ 
                                                     appendMsg "Lost one fuel box" res )
                                    Inbound     -> ( st { fuel = fuel st + 1 }
                                                   , appendMsg "Encountered jet stream" $
                                                     appendMsg "Gained one fuel box" res )
                                else (st, res)

{-
bad_weather_impact :: GameState -> Dice -> GameState
bad_weather_impact state dice
    | mod <= 4  = state
    | mod == 5  = if formation state == In then state { formation = Disrupted }
                  -- collision risk!
    | mod == 6  = if formation state == In then state { formation = Disrupted }
                  -- storm damage
                  -- collision risk
    | mod == 7  = if formation state == In then state { formation = Disrupted }
                  -- storm damage
                  -- collision risk
                  -- 1 hit to plane's electrical system
    where
        modifiers = [\d -> if {- radar out -} || {- radar operator killed -}
                                then modified_die $ val d + 1
                                else d
                    ,\d -> if {- player elected to expend an extra fuel box -}
                                then modified_die $ val d - 1
                                else d ]

        mod = val $ foldr ($) dice modifiers
-}
