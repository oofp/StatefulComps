{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE KindSignatures #-}

module EventDistrL
    (
      addMonitorL,
      removeMonitorL,
      notifyEventL,
      monitorsL
    , HasEventDistr (..)
    ) where


import Protolude
import EventDistr
import Control.Lens

class HasEventDistr ev m s | s -> ev where
  evDistr :: (MonadState s) m =>  Lens' s (EventDistributor ev m s)


--monitors :: (MonadState s) m => EventDistributorLens ev m s -> m [EventID]
--monitors this = keys <$> use (this.handlers)

monitorsL :: ((MonadState s) m, HasEventDistr ev m s) =>  m [EventID]
monitorsL = monitors evDistr

addMonitorL :: ((MonadState s) m, HasEventDistr ev m s) => EventMonitor ev m -> m EventID
addMonitorL = addMonitor evDistr

removeMonitorL :: ((MonadState s) m, HasEventDistr ev m s) => EventID -> m ()
removeMonitorL  = removeMonitor evDistr

notifyEventL :: ((MonadState s) m, HasEventDistr ev m s) => ev -> m ()
notifyEventL  = notifyEvent evDistr

{-
class HasEventDistr s where
  evDistr :: Lens' s (EventDistributor Text (StateT s IO) s)

monitorsL :: (HasEventDistr s) =>  StateT s IO [EventID]
monitorsL = monitors evDistr

class HasEventDistr2 ev s | s -> ev where
  evDistr2 :: Lens' s (EventDistributor ev (StateT s IO) s)

monitorsL2 :: (HasEventDistr2 ev s) =>  StateT s IO [EventID]
monitorsL2 = monitors evDistr2
-}
