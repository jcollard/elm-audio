CC = /usr/lib/elm/0.12.3/elm
build = build/
runtime = elm/elm-runtime.js
flags = --make --set-runtime=$(runtime) --build-dir=$(build)

all: compile

compile: build/Audio.js build/elm/ build/snd/

build/snd/:snd/
	cp snd/ build/snd/ -r

build/Audio.js:Audio.elm Native/Audio.js build/AudioTest.html
	$(CC) $(flags) -o Audio.elm

build/elm/: elm/
	cp elm/ build/ -r

build/AudioTest.html:Audio.elm AudioTest.elm Native/Audio.js
	$(CC) $(flags) AudioTest.elm


clean: build
	rm build -rf
	rm cache -rf
