extends Node3D

var pattern_one = {
	"length": 16,
	"kick":[true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false,],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var transition_fill = {
	"length": 16,
	"kick":  [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var pattern_two = {
	"length": 16,
	"kick":[true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false,],
	"hihat": [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false]
}
@onready var trigger = get_node("../TriggerArea")
func _ready():
	PatternManager.set_current_pattern(pattern_one)
	PatternManager.register_sound("kick", $kick)
	PatternManager.register_sound("snare", $snare)
	PatternManager.register_sound("hihat", $hihat)
	
	if trigger:
		trigger.player_entered.connect(_on_player_enter_room)
	else:
		push_error("Trigger Area not assigned!")

func _on_player_enter_room():
	print("Player entered the room, transitioning pattern.")
	PatternManager.trigger_transition(pattern_two, transition_fill)
