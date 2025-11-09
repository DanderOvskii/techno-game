extends Node3D


var index := 0
var is_transitioning := false

var sounds: Dictionary = {}

var current_pattern: Dictionary = {}
var next_pattern: Dictionary = {}
var transition_pattern: Dictionary = {}
var pending_transition: Dictionary = {}
var allowed_transition_beats := [0, 4, 8, 12]
func _ready():
	MusicManager.connect("beat", _on_beat)
	index = 0

func register_sound(name_sound: String, player: AudioStreamPlayer):
	if not sounds.has(name_sound):
		sounds[name_sound] = player


func _on_beat(_global_index: int):
	var pattern_to_play = transition_pattern if is_transitioning else current_pattern
	if pattern_to_play.size() == 0:
		return

	play_transition()
	_play_current_beat(pattern_to_play)
	index += 1
   

	if index >= get_pattern_length(pattern_to_play):
		index = 0
		end_transition()


func _play_current_beat(pattern_to_play: Dictionary):
	for track_name in pattern_to_play.keys():
		if track_name == "length":
			continue
		if pattern_to_play[track_name][index]:
			play_sound(track_name)

func play_sound(name_sound: String):
	if sounds.has(name_sound):
		sounds[name_sound].play()

func set_current_pattern(pattern: Dictionary):
	current_pattern = pattern
	index = 0
	is_transitioning = false
	next_pattern = {}
	transition_pattern = {}

func trigger_transition(new_pattern: Dictionary, transition: Dictionary):
	pending_transition = {
		"next_pattern": new_pattern,
		"transition_pattern": transition
	}


func play_transition():
	if pending_transition.size() > 0 and index in allowed_transition_beats:
		next_pattern = pending_transition["next_pattern"]
		transition_pattern = pending_transition["transition_pattern"]
		index = 0
		is_transitioning = true
		pending_transition = {}
		print("Starting transition to new pattern.")
		return
		


func end_transition():
	if is_transitioning:
		current_pattern = next_pattern
		next_pattern = {}
		transition_pattern = {}
		index = 0
		is_transitioning = false
		print("Transition complete, switched to new pattern.")

func get_pattern_length(pattern: Dictionary):
	for key in pattern.keys():
		return pattern[key].size()
	return 0
