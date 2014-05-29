module Audio where

{-| The Audio provides an interface for playing audio -}

import Native.Audio
import Signal
import Keyboard
import Set

{-| An Action controls how audio is heard. -}
data Action = Play | Pause | Seek Time | NoChange

{-| A Properties record contains information related to audio -}
type Properties = { duration : Time, currentTime : Time, ended : Bool }

{-| A Triggers record describes on what events you would like to receive
    a Properties record -}
type Triggers = { timeupdate : Bool, ended : Bool }

{-| The defaultTriggers is a record for ease of use. All Triggers are
    set to False. -}
defaultTriggers : Triggers
defaultTriggers = { timeupdate = False, ended = False }

{-| An Event is used to describe why the Signal returned by the
    audio function was fired.
 -}
data Event = TimeUpdate
           | Ended
           | Created

{-| A Builder Record is used to desribe how audio should be treated.
    src - The Path to an audio file
    triggers - A Triggers Record describing on which events we want to receive Properties
    propertiesHandler - A Function that is called each time Properties are calculated.
    actions - A Signal of incomming actions that manipulate the audio -}
type Builder = { src : String, 
                 triggers : Triggers, 
                 propertiesHandler : (Properties -> Maybe Action),
                 actions : Signal Action }

{-| Given a Builder, creates an Signal that fires on the specified events
    and produces the properties during those events.
-}
audio : Builder -> Signal (Event, Properties)
audio audioBuilder =
    let handleEvent =
            (\sound action ->
                     case action of
                       Play -> Native.Audio.play sound
                       Pause -> Native.Audio.pause sound
                       Seek t -> Native.Audio.seek sound t
                       NoChange -> ())
    in Native.Audio.audio 
          handleEvent
          audioBuilder.src
          audioBuilder.triggers
          audioBuilder.propertiesHandler
          audioBuilder.actions
