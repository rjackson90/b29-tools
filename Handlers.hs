{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module Handlers where

import Web.Scotty
import Network.HTTP.Types.Status
import Control.Monad.IO.Class

import qualified Data.Aeson as A
import Data.Text
import Data.Maybe
import Control.Monad.Writer.Lazy
import GHC.Generics

import State
import Weather
import Result
import qualified Charts as C
import Dice

index :: ActionM ()
index = do
    setHeader "Content-Type" "text/html"
    file "./static/app/index.html"

chartList :: [Text]
chartList = ["4-2", "4-3"]

descriptorTable :: Text -> Maybe C.ChartDescriptor
descriptorTable "4-2"   = Just $ C.get defaultWeatherInZone
descriptorTable "4-3"   = Just $ C.get defaultBadWeatherImpact
descriptorTable _       = Nothing     

listCharts :: ActionM ()
listCharts = do
    setHeader "Content-Type" "application/json"
    json $ [table | table <- [ descriptorTable x | x <- chartList ], isJust table ]
    status ok200

getChart :: ActionM ()
getChart = do
    chart <- param "chart"
    setHeader "Content-Type" "application/json"
    case descriptorTable chart of
        Just table  -> do
            json $ A.object ["descriptor" A..= table]
            status ok200
        
        Nothing     -> do
            status notFound404

postChart :: (C.Chart a) => Maybe (a, Int) -> Int -> ActionM ()
postChart maybeRequest numDice = do
    setHeader "Content-Type" "application/json"
    case maybeRequest of
        Just (initial, roll)    -> do
            case d6 numDice roll of
                Just dice   -> do
                    let (newState, results) = runWriter $ C.post initial dice
                    json $ A.object ["newState" A..= newState, "results" A..= results]
                    status ok200
                
                Nothing -> do
                    json $ A.object ["reason" A..= ("Bad Dice" :: Text)]
                    status badRequest400
        
        Nothing -> do
            json $ A.object ["reason" A..= ("Request improper for this URL" :: Text)]
            status badRequest400



error404 :: ActionM ()
error404 = do
    setHeader "Content-Type" "text/html"
    file "./static/404.html"
    status notFound404
