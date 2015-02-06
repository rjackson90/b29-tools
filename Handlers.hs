{-# LANGUAGE OverloadedStrings #-}

module Handlers where

import Web.Scotty
import Network.HTTP.Types.Status
import Control.Monad.IO.Class

import qualified Data.Aeson as A

import State
import Charts
import Result

index :: ActionM ()
index = do
    setHeader "Content-Type" "text/html"
    file "./static/index.html"

chart42 :: ActionM ()
chart42 = do
    dice <- param  "dice"
    start <- param $ "state"

    case d6 2 dice of
        Nothing     -> do
            error_cond "Invalid dice roll. Please roll 2d6"
        Just (roll) -> case A.decode start of
            Nothing             -> do
                error_cond "Invalid starting state. Please fill all fields"
            Just (old_state)    -> do 
                setHeader "Content-Type" "application/json"
                json $ A.object [ "state" A..= state, "result" A..= res ]
                status ok200
                where
                    (state, res) = weather_in_zone old_state roll
    where
        error_cond msg = do
            setHeader "Content-Type" "application/json"
            json $ A.object [ "result" A..= neg_result msg  ]
            status badRequest400
        neg_result text = result Error Neg text

defaultState :: ActionM ()
defaultState = do
    setHeader "Content-Type" "application/json"
    json $ GameState
        { altitude = Low
        , weather = Good
        , direction = Outbound
        , fuel = 32
        , formation = Out}
    status ok200

error404 :: ActionM ()
error404 = do
    setHeader "Content-Type" "text/html"
    file "./static/404.html"
    status notFound404
