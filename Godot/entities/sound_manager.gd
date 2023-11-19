class_name SoundManager extends Node

var root: RootScene
var sounds: Dictionary = {}

func play(sound: String, loop = false):
	var audio_player = AudioStreamPlayer.new()
	var soundPath = root.data.getSound(sound)
	audio_player.stream = load("res:/" + soundPath)
	add_child(audio_player)
	sounds[soundPath] = audio_player
	if audio_player.is_inside_tree():
		audio_player.stream.loop = loop
		audio_player.play()

func stopSound(sound: String):
	var soundPath = root.data.getSound(sound)
	if sounds.has(soundPath):
		remove_child(sounds[soundPath])
		sounds.erase(soundPath)

func stopSounds():
	for sound in sounds:
		remove_child(sounds[sound])
		sounds.erase(sound)
