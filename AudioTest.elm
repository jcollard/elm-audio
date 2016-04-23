import Audio
import Audio exposing (defaultTriggers)
import Signal exposing (..)
import Keyboard
import Char
import Text
import Graphics.Element exposing (..)
import List

-- We are either Playing or Not Playing
type alias State = { playing : Bool }

-- We start by not Playing
initialState : State
initialState = { playing = False }

-- When the p key is pressed, we toggle the playing state
update : Char.KeyCode -> State -> State
update key state =
    if key == Char.toCode 'p'
    then {state | playing = not state.playing}
    else state

-- Be Stateful!
stateful : Signal State
stateful = foldp update initialState Keyboard.presses

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
                        triggers = {defaultTriggers | timeupdate = True},
                        propertiesHandler = propertiesHandler,
                        actions = map handleAudio stateful }

-- A Simple Display
display : (State, (Audio.Event, Audio.Properties)) -> Element
display (state, (event, properties)) =
    let playing = if state.playing then "Playing" else "Paused"
        progress = "Current Time: " ++ toString (properties.currentTime)
        duration = "Duration: " ++ toString (properties.duration)
    in flow down <| List.map (leftAligned << Text.fromString)
           [ "Tap 'P' to toggle between playing and paused."
           , playing
           , progress
           , duration
           ]

main = let output = map2 (,) stateful builder in map display output
