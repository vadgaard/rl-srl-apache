{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# HLINT ignore "Redundant <$>" #-}

module RLSRL ( rlsrl ) where

import System.Timeout ( timeout )
import System.Environment ( getArgs )
import qualified Data.ByteString.Lazy as BSL
import Data.Text
import Data.Text.Encoding

import qualified RL.Interface
import qualified SRL.Interface
import JSON
    ( ErrorResult(ErrorResult),
      RunResult(RunResult),
      VarTabContainer(VarTabContainer),
      ToJSON,
      badRequest,
      requestTimeout,
      encodePretty )

timeoutTimeSec :: Int
timeoutTimeSec = 2
timeoutTimeUSec :: Int
timeoutTimeUSec = timeoutTimeSec * 1000000

rlsrl :: IO ()
rlsrl = handleArgs <$> getArgs >>= \case
  Just (lang, mode, setLog, script) ->
    case lang of
      ArgRL -> case mode of
        ArgRun -> do
          response <- timeout timeoutTimeUSec $ RL.Interface.runProgram script
          case response of
            Nothing -> do
              putStrLn . getJSON $ requestTimeout
            Just (res, trace) -> do
              case res of
                Left err -> (if setLog then putStrLn . getJSON $ ErrorResult (err, trace) else putStrLn . getJSON $ err)
                Right vtab -> (if setLog then putStrLn . getJSON $ RunResult (vtab, trace) else putStrLn . getJSON $ VarTabContainer vtab)
        ArgInvert -> do
          response <- timeout timeoutTimeUSec $ RL.Interface.invertProgram script
          case response of
            Nothing -> do
              putStrLn . getJSON $ requestTimeout
            Just res -> do
              case res of
                Left err -> putStrLn . getJSON $ err
                Right program -> putStrLn . getJSON $ program
        ArgTranslate -> do
          response <- timeout timeoutTimeUSec $ RL.Interface.translateProgram script
          case response of
            Nothing -> do
              putStrLn . getJSON $ requestTimeout
            Just res -> do
              case res of
                Left err -> putStrLn . getJSON $ err
                Right program -> putStrLn . getJSON $ program
      ArgSRL -> case mode of
        ArgRun -> do
          response <- timeout timeoutTimeUSec $ SRL.Interface.runProgram script
          case response of
            Nothing -> do
              putStrLn . getJSON $ requestTimeout
            Just (res, trace) -> do
              case res of
                Left err -> (if setLog then putStrLn . getJSON $ ErrorResult (err, trace) else putStrLn . getJSON $ err)
                Right vtab -> (if setLog then putStrLn . getJSON $ RunResult (vtab, trace) else putStrLn . getJSON $ VarTabContainer vtab)
        ArgInvert -> do
          response <- timeout timeoutTimeUSec $ SRL.Interface.invertProgram script
          case response of
            Nothing -> do
              putStrLn . getJSON $ requestTimeout
            Just res -> do
              case res of
                Left err -> putStrLn . getJSON $ err
                Right program -> putStrLn . getJSON $ program
        ArgTranslate -> do
          response <- timeout timeoutTimeUSec $ SRL.Interface.translateProgram script
          case response of
            Nothing -> do
              putStrLn . getJSON $ requestTimeout
            Just res -> do
              case res of
                Left err -> putStrLn . getJSON $ err
                Right program -> putStrLn . getJSON $ program
  Nothing -> putStrLn . getJSON $ badRequest

getJSON :: ToJSON a => a -> String
getJSON d = unpack $ decodeUtf8 $ BSL.toStrict (encodePretty d)

data LangArg   = ArgRL | ArgSRL
data ModeArg   = ArgRun | ArgInvert | ArgTranslate
type LogArg    = Bool
type ScriptArg = String

handleArgs :: [String] -> Maybe (LangArg, ModeArg, LogArg, ScriptArg)
handleArgs args = do
  (l, m, t, script) <- case args of
    [a, b, c, d] -> Just (a, b, c, d)
    [a, b, c]    -> Just (a, b, "false", c)
    _            -> Nothing
  lang <- case l of
    "rl" -> Just ArgRL
    "srl" -> Just ArgSRL
    _ -> Nothing
  mode <- case m of
    "run"       -> Just ArgRun
    "invert"    -> Just ArgInvert
    "translate" -> Just ArgTranslate
    _           -> Nothing
  trace <- case t of
    "true" -> Just True
    _   -> Just False

  return (lang, mode, trace, script)
