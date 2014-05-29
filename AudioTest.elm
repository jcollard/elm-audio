import Audio
import Audio(defaultTriggers)
import Signal
import Keyboard
import Char
import Text

-- We are either Playing or Not Playing
type State = { playing : Bool }

-- We start by not Playing
initialState : State
initialState = { playing = False }

-- When the p key is pressed, we toggle the playing state
update : Char.KeyCode -> State -> State
update key state = 
    if key == Char.toCode 'p' 
    then {state | playing <- not state.playing}
    else state

-- Be Stateful!
stateful : Signal State
stateful = foldp update initialState Keyboard.lastPressed 

-- If we've reached 37.6 seconds into the piece, jump to 0.05.
propertiesHandler : Audio.Properties -> Maybe Audio.Action
propertiesHandler properties =
    if properties.currentTime > 37.6 then Just (Audio.Seek 0.05) else Nothing

-- If the State says we are playing, Play else Pause
handleAudio : State -> Audio.Action
handleAudio state =
    if state.playing then Audio.Play
    else Audio.Pause

-- Audio Player with Tetris Theme that triggers when the time changes
-- The property Handler will loop at the correct time.
builder : Signal (Audio.Event, Audio.Properties)
builder = Audio.audio { src = "snd/theme.mp3",
                        triggers = {defaultTriggers | timeupdate <- True},
                        propertiesHandler = propertiesHandler,
                        actions = handleAudio <~ stateful }

-- A Simple Display
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