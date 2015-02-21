{-# LANGUAGE OverloadedStrings #-}
import Network.Wai.Middleware.Static
import Network.Wai.Middleware.Gzip
import Web.Scotty

import qualified Data.Aeson as A
import qualified Data.Aeson.Types as AT
import qualified Data.ByteString.Lazy.Char8 as BL

import Handlers
import qualified Charts as C
import Weather

main = scotty 3000 $ do
    -- Middleware
    middleware $ staticPolicy (noDots >-> isNotAbsolute)
    middleware $ gzip $ def { gzipFiles = GzipCompress }
    
    -- Routes
    get "/" $ index     -- Only for development testing!

    get "/api/charts/list.json" listCharts
    get "/api/charts/:chart" getChart

    post "/api/charts/4-2" $ do
        request <- body
        let maybeRequest = decodeRequest request :: Maybe (WeatherInZone, Int)
        postChart maybeRequest 2

    post "/api/charts/4-3" $ do
        request <- body
        let maybeRequest = decodeRequest request :: Maybe (BadWeatherImpact, Int)
        postChart maybeRequest 1

    notFound $ error404

decodeRequest :: (C.Chart a) => BL.ByteString -> Maybe (a, Int)
decodeRequest request = do 
    root <- A.decode request
    flip AT.parseMaybe root $ \obj -> do
        state <- obj A..: "state"
        roll <- obj A..: "roll"
        return (state, roll)
