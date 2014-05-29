module Audio where

{-| The Audio provides an interface for playing audio -}

import Native.Audio
import Signal
import Keyboard
import Set

data Action = Play | Pause | Seek Time

type Properties = { duration : Time, currentTime : Time, ended : Bool }

type Triggers = { timeupdate : Bool, ended : Bool }

defaultTriggers : Triggers
defaultTriggers = { timeupdate = False, ended = False }

data Event = TimeUpdate
           | Ended
           | Created

type Builder = { src : String, 
                 triggers : Triggers, 
                 propertiesHandler : (Properties -> Maybe Action),
                 actions : Signal Action }

audio : Builder -> Signal (Event, Properties)
audio audioBuilder =
    let handleEvent =
            (\sound action ->
                     case action of
                       Play -> Native.Audio.play sound
                       Pause -> Native.Audio.pause sound
                       Seek t -> Native.Audio.seek sound t)
    in Native.Audio.audio 
          handleEvent
          audioBuilder.src
          audioBuilder.triggers
          audioBuilder.propertiesHandler
          audioBuilder.actions
