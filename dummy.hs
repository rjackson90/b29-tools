{-# LANGUAGE OverloadedStrings, DeriveGeneric, GADTs, StandaloneDeriving #-}

import GHC.Generics

import Data.Maybe
import Data.Text
import qualified Data.ByteString.Lazy as BL
import Data.Aeson
import Data.Aeson.Types
import Control.Monad.Writer.Lazy
import Control.Applicative

import Charts
import Weather
import Result
import Dice

jsonRequest :: BL.ByteString
jsonRequest = "\
    \{  \"state\" : {\
    \   \"altitude\":\"High\",\
    \   \"weather\":\"Poor\",\
    \   \"fuel\":16,\
    \   \"direction\":\"Outbound\"\
    \   },\
    \   \"roll\":8\
    \}"

main :: IO ()
main = do
    -- Test the "Parse then dispatch" method
    putStrLn "Does it parse?"
    case decodeRequest jsonRequest of
        Just (initial, roll)    -> do
            putStrLn "It sure does!"
            putStrLn . show $ (initial :: WeatherInZone)
            case d6 2 roll of
                Just dice   -> do
                    let (final, results) = runWriter $ post initial dice
                    BL.putStrLn . encode $ object ["newState" .= final, "results" .= results]
                Nothing -> do
                    putStrLn "Invalid dice!"

        Nothing -> do
            putStrLn "That's a big ol' Negatory, Space Captain!"

    putStrLn ""
    
    -- Test the "Stupid Hacky Bullshit" method
    putStrLn "Does stupid hacky bullshit get the job done?"
    let maybeRequest= decode jsonRequest :: Maybe WeatherInZoneRequest
    case maybeRequest of
        Just request    -> do
            putStrLn "Damn skippy it does!"
            putStrLn . show $ state request
            case d6 2 $ roll request of
                Just dice   -> do
                    let (final, results) = runWriter $ post (state request) dice
                    BL.putStrLn . encode $ object ["newState" .= final, "results" .= results]
                Nothing -> do
                    putStrLn "Invalid dice!"

        Nothing ->
            putStrLn "Nope, that doesn't work either!"

    putStrLn ""

    -- Attempt to separate out the parsing of JSON from the handling of requests
    case decodeRequest jsonRequest of
        Just (initial, roll)   -> do
            case d6 2 roll of
                Just dice   -> do
                    BL.putStrLn $ postChart (initial :: WeatherInZone) dice
                Nothing -> do
                    putStrLn "Bad dice response"
        Nothing -> do
            putStrLn "Bad data response"

data WeatherInZoneRequest = WeatherInZoneRequest
    { state :: WeatherInZone
    , roll :: Int } deriving(Show, Generic)
instance FromJSON WeatherInZoneRequest
instance ToJSON WeatherInZoneRequest

decodeRequest :: (Chart a) => BL.ByteString -> Maybe (a, Int)
decodeRequest request = do
    root <- decode request
    flip parseMaybe root $ \obj -> do
        state <- obj .: "state"
        roll <- obj .: "roll"
        return (state, roll)

postChart :: (Chart a) => a -> Dice -> BL.ByteString
postChart initial dice = encode $ object ["newState" .= final, "results" .= results]
    where
        (final, results) = runWriter $ post initial dice

