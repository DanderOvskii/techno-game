extends Node3D


var index := 0
var is_transitioning := false

var sounds: Dictionary = {}

var current_pattern: Dictionary = {}
var next_pattern: Dictionary = {}
var transition_pattern: Dictionary = {}
var pending_transition: Dictionary = {}

var current_sound_set: Dictionary = {}
var _transition_sound_set: Dictionary = {}
var _next_sound_set: Dictionary = {}

var ALLOWED_TRANSITION_BEATS := [0, 4, 8, 12]
func _ready():
	MusicManager.connect("beat", _on_beat)
	index = 0



func _on_beat(_global_index: int):
	var pattern_to_play = transition_pattern if is_transitioning else current_pattern
	if pattern_to_play.size() == 0:
		return

	_try_start_pending_transition()
	_play_current_beat(pattern_to_play)
	index += 1
   

	if index >= get_pattern_length(pattern_to_play):
		index = 0
		_finish_transition()


func _play_current_beat(pattern_to_play: Dictionary):
	for track_name in pattern_to_play.keys():
		if track_name == "length":
			continue
		if pattern_to_play[track_name][index]:
			play_sound(track_name)

#sounds and samples
func register_sound(name_sound: String, player: AudioStreamPlayer):
	if not sounds.has(name_sound):
		sounds[name_sound] = player

func play_sound(name_sound: String):
	if sounds.has(name_sound):
		sounds[name_sound].play()

func apply_sound_set(sound_set: Dictionary):
	if sound_set.size() == 0:
		return
	for name_sound in sound_set.keys():
		if sounds.has(name_sound):
			sounds[name_sound].stream = sound_set[name_sound]


#patterns and transitions
func set_current_pattern(pattern: Dictionary, sound_set: Dictionary = {}):
	current_pattern = pattern
	index = 0
	is_transitioning = false
	next_pattern = {}
	transition_pattern = {}
	if sound_set and sound_set.size() > 0:
		apply_sound_set(sound_set)
		current_sound_set = sound_set
	else:
		current_sound_set = current_sound_set

func trigger_transition(new_pattern: Dictionary, transition: Dictionary, transition_sound_set: Dictionary = {}, next_sound_set: Dictionary = {}):
	if  next_sound_set.size() == 0:
		next_sound_set = current_sound_set
	pending_transition = {
		"next_pattern": new_pattern,
		"transition_pattern": transition,
		"transition_sound_set": transition_sound_set,
		"next_sound_set": next_sound_set
	}


func _try_start_pending_transition():
	if  pending_transition.size() == 0:
		return
	
	if index in ALLOWED_TRANSITION_BEATS:
		next_pattern = pending_transition["next_pattern"]
		transition_pattern = pending_transition["transition_pattern"]
		_transition_sound_set = pending_transition["transition_sound_set"]
		_next_sound_set = pending_transition["next_sound_set"]
		if _transition_sound_set and _transition_sound_set.size() > 0:
			apply_sound_set(_transition_sound_set)
		index = 0
		is_transitioning = true
		pending_transition = {}
		print("Starting transition to new pattern.")
		return
		


func _finish_transition():
	if not is_transitioning:
		return
	current_pattern = next_pattern
	next_pattern = {}
	transition_pattern = {}
	index = 0
	is_transitioning = false
	if _next_sound_set and _next_sound_set.size() > 0:
		apply_sound_set(_next_sound_set)
		current_sound_set = _next_sound_set
		_next_sound_set = {}
	# clear transition sound set after finishing
	_transition_sound_set = {}
	print("Transition complete, switched to new pattern.")

func get_pattern_length(pattern: Dictionary):
	for key in pattern.keys():
		return pattern[key].size()
	return 0
