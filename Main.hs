{-# LANGUAGE OverloadedStrings #-}
import Network.Wai.Middleware.Static
import Network.Wai.Middleware.Gzip

import Web.Scotty

import Handlers

main = scotty 3000 $ do
    -- Middleware
    middleware $ staticPolicy (noDots >-> isNotAbsolute)
    middleware $ gzip $ def { gzipFiles = GzipCompress }
    
    -- Routes
    get "/" $ index
    get "/charts/4-2" $ getWeatherInZone
    get "/charts/4-3" $ getBadWeatherImpact
    notFound $ error404
