module Charts 
( weather_in_zone 
) where

import State

weather_in_zone :: GameState -> Dice -> GameState
weather_in_zone state dice   
        | mod <= 2              = jet_stream state { weather = Good }
        | mod >= 3 && mod <= 8  = state { weather = Good }
        | mod == 9              = state { weather = Poor }
        | mod == 10             = jet_stream state { weather = Poor }
        | mod == 11             = jet_stream state { weather = Bad }
        | mod >= 12             = state { weather = Bad }
    
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

        jet_stream :: GameState -> GameState
        jet_stream st = if altitude st == High 
                            then case direction st of
                                    Outbound    -> st { fuel = fuel st - 1 }
                                    Inbound     -> st { fuel = fuel st + 1 }
                            else st
