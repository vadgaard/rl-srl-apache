{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# HLINT ignore "Redundant <$>" #-}

module RLSRL ( rlsrl ) where

import System.Timeout ( timeout )
import System.Environment ( getArgs )

import qualified RL.Interface
import qualified SRL.Interface
import JSON
    ( ErrorResult(ErrorResult),
      RunResult(RunResult),
      VarTabContainer(VarTabContainer),
      badRequest,
      requestTimeout,
      encodePretty )

timeoutTimeSec :: Int
timeoutTimeSec = 6
timeoutTimeUSec :: Int
timeoutTimeUSec = timeoutTimeSec * 1000000

rlsrl :: IO ()
rlsrl = handleArgs <$> getArgs >>= \case
  Just (lang, mode, setLog, script) ->
    case lang of
      ArgRL -> case mode of
        ArgRun -> do
          putStrLn "Running RL program!"
          response <- timeout timeoutTimeUSec $ RL.Interface.runProgram script
          case response of
            Nothing -> do
              putStrLn "It timed out!"
              print . encodePretty $ requestTimeout
            Just (res, trace) -> do
              putStrLn "Executed successfully!"
              case res of
                Left err -> (if setLog then print . encodePretty $ ErrorResult (err, trace) else print . encodePretty $ err)
                Right vtab -> (if setLog then print . encodePretty $ RunResult (vtab, trace) else print . encodePretty $ VarTabContainer vtab)
        ArgInvert -> do
          putStrLn "Inverting RL program!"
          response <- timeout timeoutTimeUSec $ RL.Interface.invertProgram script
          case response of
            Nothing -> do
              putStrLn "It timed out!"
              print . encodePretty $ requestTimeout
            Just res -> do
              putStrLn "Inverted successfully!"
              case res of
                Left err -> print . encodePretty $ err
                Right program -> print . encodePretty $ program
        ArgTranslate -> do
          putStrLn "Translating RL program!"
          response <- timeout timeoutTimeUSec $ RL.Interface.translateProgram script
          case response of
            Nothing -> do
              putStrLn "It timed out!"
              print . encodePretty $ requestTimeout
            Just res -> do
              putStrLn "It didn't time out!"
              case res of
                Left err -> print . encodePretty $ err
                Right program -> print . encodePretty $ program
      ArgSRL -> case mode of
        ArgRun -> do
          putStrLn "Running SRL program!"
          response <- timeout timeoutTimeUSec $ SRL.Interface.runProgram script
          case response of
            Nothing -> do
              putStrLn "It timed out!"
              print . encodePretty $ requestTimeout
            Just (res, trace) -> do
              putStrLn "Executed successfully!"
              case res of
                Left err -> (if setLog then print . encodePretty $ ErrorResult (err, trace) else print . encodePretty $ err)
                Right vtab -> (if setLog then print . encodePretty $ RunResult (vtab, trace) else print . encodePretty $ VarTabContainer vtab)
        ArgInvert -> do
          putStrLn "Inverting SRL program!"
          response <- timeout timeoutTimeUSec $ SRL.Interface.invertProgram script
          case response of
            Nothing -> do
              putStrLn "It timed out!"
              print . encodePretty $ requestTimeout
            Just res -> do
              putStrLn "Inverted successfully!"
              case res of
                Left err -> print . encodePretty $ err
                Right program -> print . encodePretty $ program
        ArgTranslate -> do
          putStrLn "Translating SRL program!"
          response <- timeout timeoutTimeUSec $ SRL.Interface.translateProgram script
          case response of
            Nothing -> do
              putStrLn "It timed out!"
              print . encodePretty $ requestTimeout
            Just res -> do
              putStrLn "It didn't time out!"
              case res of
                Left err -> print . encodePretty $ err
                Right program -> print . encodePretty $ program
  Nothing -> print . encodePretty $ badRequest

data LangArg   = ArgRL | ArgSRL
data ModeArg   = ArgRun | ArgInvert | ArgTranslate
type LogArg    = Bool
type ScriptArg = String

handleArgs :: [String] -> Maybe (LangArg, ModeArg, LogArg, ScriptArg)
handleArgs args = do
  (l, m, t, script) <- case args of
    [a, b, c, d] -> Just (a, b, c, d)
    [a, b, c]    -> Just (a, b, "0", c)
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
    "0" -> Just False
    _   -> Just True

  return (lang, mode, trace, script)
