# StatefulComps : stateful  pure reusable components

## EventDistributor - simple pub/sub component that is incorporated into `MonadState`

### Brief instructions:

* Add EventDistributor to your as member of state record, like:  
`data MyState=MyState {_distr::EventDistributor MyEvent (StateT MyState IO) MyState, _counter :: Int}`,

  where EventDistributor is parameterized by event type , monad (that is instance of MonadState and state type):

* when creating you state , use `newEventDistributor :: EventDistributor ev m s` to create new distributor

* The rest of the function use Lenses to publish event, subscribe to events and remove subscribers. Here is type alias is used to refer to distributor:

  - `type EventDistributorLens ev m s = Lens' s (EventDistributor ev m s)`



* `addMonitor :: (MonadState s) m => EventDistributorLens ev m s -> EventMonitor ev m -> m EventID`
 - add subscriber (monitor event), where EventMonitor is record with both event filter and event handler:
    `data EventMonitor ev m= EventMonitor {filter :: ev->Bool, handler :: EventHandler ev m}`

    `type EventHandler ev m = EventID -> ev -> m Bool`

  - EventID is used for the reference and also allows removing subscription (stop monitoring)
  - Boolean value returned by event handler indicates whether event need to continue once handling is completed (True to continue, False to cancel monitoring)
  - Note that handler is executed in the same monadic context as the hosting monad (so IO or state changes are allowed)



* `addMonitorWithTrans :: (MonadState s) m => EventDistributorLens ev m s -> (ev->Maybe ev') -> EventHandler ev' m -> m EventID`
  - convinice method that allows passing (ev->Maybe ev') function instead of predicate to allow both filtering and conversion of monitored event


* `removeMonitor :: (MonadState s) m => EventDistributorLens ev m s -> EventID -> m ()``

  - remove monitor using EventID returned by `addMonitor`
  - alternatively monitor can be removed by returning False from event handler

*
