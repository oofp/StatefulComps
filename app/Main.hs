{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module Main where

import Protolude
import EventDistr
import EventDistrL
import Control.Lens
import qualified Data.Text as T
newtype MyEvent = MyEvent {evText :: Text}
data MyState=MyState {_distr::EventDistributor MyEvent (StateT MyState IO) MyState, _counter :: Int}

makeLenses ''MyState

instance HasEventDistr MyEvent (StateT MyState IO) MyState where
  evDistr = distr

main :: IO ()
main = do
  putStrLn ("Hello"::Text)
  (_, finalState) <- runStateT myStateProcL (MyState newEventDistributor 0)
  putStrLn (("Loops done:"::Text) <> show (finalState^.counter))

myStateProc :: StateT MyState IO ()
myStateProc = do
    _evID1 <- addMonitor distr counterMonitor
    _evID2 <- addMonitor distr evenMonitor
    _evID3 <- addMonitor distr oddMonitor
    loop
  where
    counterMonitor = EventMonitor (const True) (\_ _->  (counter %= (+1))>>return True)
    evenMonitor = EventMonitor (even . T.length . evText) (\evID ev -> putStrLn ("ID:" <> show evID <> "; Even string detected:" <> evText ev)>>return True)
    oddMonitor = EventMonitor (odd . T.length . evText) (\evID ev -> putStrLn ("ID:" <> show evID <> "; Odd string detected:" <> evText ev)>>return True)
    loop = do
      liftIO $ putStrLn ("Next text pls (q to exit):"::Text)
      txt <- liftIO getLine
      notifyEvent distr (MyEvent txt)
      unless (txt=="q") loop

myStateProcL :: StateT MyState IO ()
myStateProcL = do
    _evID1 <- addMonitorL counterMonitor
    _evID2 <- addMonitorL evenMonitor
    _evID3 <- addMonitorL oddMonitor
    loop
  where
    counterMonitor = EventMonitor (const True) (\_ _->  (counter %= (+1))>>return True)
    evenMonitor = EventMonitor (even . T.length . evText) (\evID ev -> putStrLn ("ID:" <> show evID <> "; Even string detected:" <> evText ev)>>return True)
    oddMonitor = EventMonitor (odd . T.length . evText) (\evID ev -> putStrLn ("ID:" <> show evID <> "; Odd string detected:" <> evText ev)>>return True)
    loop = do
      liftIO $ putStrLn ("Next text pls (q to exit):"::Text)
      txt <- liftIO getLine
      notifyEventL (MyEvent txt)
      unless (txt=="q") loop
