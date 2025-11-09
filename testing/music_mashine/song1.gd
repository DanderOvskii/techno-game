extends Node3D
@export var kick: AudioStreamPlayer
@export var snare: AudioStreamPlayer
@export var hihat: AudioStreamPlayer

var pattern_one = {
	"kick":	 [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false,],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var transition_fill = {
	"kick":  [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var pattern_two = {
	"kick":  [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false,],
	"hihat": [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false]
}

func _ready():
	PatternManager.set_current_pattern(pattern_one)
	PatternManager.register_sound("kick", kick)
	PatternManager.register_sound("snare", snare)
	PatternManager.register_sound("hihat", hihat)
	
	for trigger in get_tree().get_nodes_in_group("music_areas"):
		if trigger:
			trigger.player_entered.connect(_on_player_enter_room)
		else:
			push_error("Trigger Area not assigned!")

func _on_player_enter_room(AreaId: int):
	print("Player entered area %s" % AreaId)
	match AreaId:
		1:
			PatternManager.trigger_transition(pattern_two, transition_fill)
		2:
			PatternManager.trigger_transition(pattern_one, transition_fill)
		_:
			print("Transition triggered by unknown area")
			PatternManager.trigger_transition(pattern_two, transition_fill)