{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Aeson (decode)
import Data.Aeson.Encode.Pretty (encodePretty)
import Data.Aeson.Types (Value, emptyObject)
import Data.ByteString.Lazy (toStrict)
import Data.ByteString.UTF8 (toString)
import Data.Maybe
import Data.Time.LocalTime (getZonedTime)
import Network.HTTP.Types
import Network.Wai
import Network.Wai.Handler.Warp
import System.IO
import Data.List (isPrefixOf)

main :: IO ()
main = run 7777 requestLogger

logFile :: FilePath
logFile = "/var/log/requests.log"

requestLogger :: Application
requestLogger request respond = do
  withFile
    logFile
    AppendMode
    (\handle -> do
       currentTime <- getZonedTime
       hPutStrLn handle $ "========== " <> show currentTime <> " =========="
       hPrint handle request
       hPutStrLn handle "Body:"
       bodyBytes <- strictRequestBody request
       let headers = requestHeaders request
           contentType = toString $ fromMaybe "" (lookup hContentType headers)
       if "application/json" `isPrefixOf` contentType
         then do
           let bodyJson = fromMaybe emptyObject . decode $ bodyBytes
           hPutStrLn handle (toString . toStrict . encodePretty $ bodyJson)
         else hPutStrLn handle (toString . toStrict $ bodyBytes)
       hPutStrLn handle ""
    )
  respond $ responseLBS status200 [] ""
