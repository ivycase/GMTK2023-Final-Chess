extends Node

var audio = preload("res://scenes/audio.tscn")
var audio_sources = []
var persistent_sources = []

func play(filename, bus="Master", looping=false, persistent=false):
	var new_audio = audio.instantiate()
	
	add_child(new_audio)
	if persistent: persistent_sources.append(new_audio)
	else: audio_sources.append(new_audio)
	
	new_audio.stream = load("res://sounds/" + filename) 
	new_audio.bus = bus
	new_audio.play()
	
	if !looping:
		await new_audio.finished
		audio_sources.erase(new_audio)
		new_audio.queue_free()

func clear():
	while len(audio_sources) > 0:
		var source = audio_sources[0]
		if source.playing: await source.finished
		source.queue_free()
		if len(audio_sources) > 0: audio_sources.remove_at(0)
		
func clear_persistent():
	while len(persistent_sources) > 0:
		persistent_sources[0].queue_free()
		persistent_sources.remove_at(0)
