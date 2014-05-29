
Elm.Native.Audio = {};
Elm.Native.Audio.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.Audio = elm.Native.Audio || {};
    if (elm.Native.Audio.values) return elm.Native.Audio.values;

    var Signal = Elm.Native.Signal.make(elm);
    var Maybe = Elm.Maybe.make(elm);
    var audioRecords = new Array();
    var nextID = 0;

    var TimeUpdate = {ctor : "TimeUpdate"};
    var Ended = {ctor : "Ended"};
    var Created = {ctor : "Created"};

    function Tuple2(fst, snd){
        return {ctor: "_Tuple2", _0 : fst, _1 : snd};
    }

    function Properties(duration, currentTime, ended){
        return { _ : {}, duration : duration, currentTime : currentTime, ended : ended};
    }


    function audio(handler, path, alerts, propHandler, actions) {
        var sound = new Audio(path);
        var event = Signal.constant(Tuple2(Created, Properties(0,0,0)));
        var handle = handler(nextID);
        audioRecords[nextID++] = sound;
        Signal.lift(handle)(actions);

        function addAudioListener(eventString, eventConst){
            sound.addEventListener(eventString, function () {
                var props = Properties(sound.duration, sound.currentTime, sound.ended);
                elm.notify(event.id, Tuple2(eventConst, props));
                var action = propHandler(props);
                if(Maybe.isJust(action))
                    handle(action._0)
            });
        }

        if(alerts.timeupdate)
            addAudioListener('timeupdate', TimeUpdate);

        if(alerts.ended)
            addAudioListener('ended', Ended);

        return event;
    }

    function play(id){
        if(!audioRecords[id]) return;
        audioRecords[id].play();
    }

    function pause(id){
        if(!audioRecords[id]) return;
        audioRecords[id].pause()
    }

    function seek(id, time){
        if(!audioRecords[id]) return;
        audioRecords[id].currentTime = time;
    }

    return elm.Native.Audio.values = {
        audio : F5(audio),
        play : play,
        pause : pause,
        seek : F2(seek)
    };

};

