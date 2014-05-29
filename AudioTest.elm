import Audio
import Audio(defaultTriggers)
import Signal
import Keyboard
import Char
import Text

type State = { playing : Bool }

initialState : State
initialState = { playing = False }

update : Char.KeyCode -> State -> State
update key state = 
    if key == Char.toCode 'p' 
    then {state | playing <- not state.playing}
    else state

stateful : Signal State
stateful = foldp update initialState Keyboard.lastPressed 

propertiesHandler : Audio.Properties -> Maybe Audio.Action
propertiesHandler properties =
    if properties.currentTime > 37.6 then Just (Audio.Seek 0.05) else Nothing

handleAudio : State -> Audio.Action
handleAudio state =
    if state.playing then Audio.Play
    else Audio.Pause

builder : Signal (Audio.Event, Audio.Properties)
builder = Audio.audio { src = "snd/theme.mp3",
                        triggers = {defaultTriggers | timeupdate <- True},
                        propertiesHandler = propertiesHandler,
                        actions = handleAudio <~ stateful }

display : (State, (Audio.Event, Audio.Properties)) -> Element
display (state, (event, properties)) =
    let playing = if state.playing then "Playing" else "Paused"
        progress = "Current Time: " ++ show (properties.currentTime)
        duration = "Duration: " ++ show (properties.duration)
    in flow down <| map (Text.leftAligned . Text.toText) 
           ["Tap 'P' to toggle between playing and paused.", 
            playing,
            progress,
            duration]

main = let output = (,) <~ stateful ~ builder in display <~ output