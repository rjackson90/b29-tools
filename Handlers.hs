{-# LANGUAGE OverloadedStrings #-}

module Handlers where

import Web.Scotty
import Network.HTTP.Types.Status
import Control.Monad.IO.Class

import qualified Data.Aeson as A
import Data.Text

import State
import Weather
import Result
import qualified Charts as C

index :: ActionM ()
index = do
    setHeader "Content-Type" "text/html"
    file "./static/app/index.html"

getWeatherInZone :: ActionM ()
getWeatherInZone = getChart . C.get $ defaultWeatherInZone

getBadWeatherImpact :: ActionM ()
getBadWeatherImpact = getChart . C.get $ defaultBadWeatherImpact

getChart :: C.ChartDescriptor -> ActionM ()
getChart descriptor = do
    setHeader "Content-Type" "application/json"
    json $ A.object ["descriptor" A..= descriptor]
    status ok200

error404 :: ActionM ()
error404 = do
    setHeader "Content-Type" "text/html"
    file "./static/404.html"
    status notFound404
