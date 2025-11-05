extends Node3D

@export var bpm := 160
@export var kick: AudioStreamPlayer
@export var snare: AudioStreamPlayer
@export var hihat: AudioStreamPlayer

@export var pattern_kick = [1, 1, 1, 1]
@export var pattern_snare = [1, 1, 1, 1]
@export var pattern_hihat = [1, 1, 1, 1]
var index :=0
var beat := 60.0/bpm
var time_accumulator = 0.0

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= beat:
		time_accumulator-=beat
		
		var current_beat = pattern_kick[index]
	
		if current_beat == 1:
			kick.play()
	
		index += 1 
		if index >= pattern_kick.size():
			index = 0
	
