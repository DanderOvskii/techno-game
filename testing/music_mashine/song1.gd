extends Node3D
@export var kick: AudioStreamPlayer
@export var snare: AudioStreamPlayer
@export var hihat: AudioStreamPlayer

var pattern_kick_snare = {
	"kick":	 [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false,],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var sound_set_boring={
	"kick": preload("res://testing/music_mashine/samples/House Kick 37.wav"),
	"snare": preload("res://testing/music_mashine/samples/House Snare 16.wav"),
	"hihat": preload("res://testing/music_mashine/samples/House HiHat 01.wav")
}

var transition_fill = {
	"kick":  [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var sound_set_transition={
	"kick": preload("res://testing/music_mashine/samples/TKNVLT_FREE_HT_SCHRANZ_KICK_160_1.wav"),
	"snare": preload("res://testing/music_mashine/samples/House Snare 16.wav"),
	"hihat": preload("res://testing/music_mashine/samples/House HiHat 01.wav")
}

var pattern_kick = {
	"kick":  [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false],
	"snare": [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false,],
	"hihat": [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
}

var sound_set_explosive_kick={
	"kick": preload("res://testing/music_mashine/samples/TKNVLT_FREE_HT_SCHRANZ_KICK_160_3.wav"),
	"snare": preload("res://testing/music_mashine/samples/House Snare 16.wav"),
	"hihat": preload("res://testing/music_mashine/samples/House HiHat 01.wav")
}

func _ready():
	PatternManager.register_sound("kick", kick)
	PatternManager.register_sound("snare", snare)
	PatternManager.register_sound("hihat", hihat)
	PatternManager.set_current_pattern(pattern_kick_snare, sound_set_boring)
	
	for trigger in get_tree().get_nodes_in_group("music_areas"):
		if trigger:
			trigger.player_entered.connect(_on_player_enter_room)
		else:
			push_error("Trigger Area not assigned!")

func _on_player_enter_room(AreaId: int):
	print("Player entered area %s" % AreaId)
	match AreaId:
		1:
			PatternManager.trigger_transition(pattern_kick, transition_fill, sound_set_transition,sound_set_explosive_kick)
		2:
			PatternManager.trigger_transition(pattern_kick_snare, transition_fill,sound_set_transition)
		3:
			PatternManager.set_current_pattern(pattern_kick_snare, sound_set_boring)
		_:
			print("Transition triggered by unknown area")
			PatternManager.trigger_transition(pattern_kick, transition_fill, sound_set_transition,sound_set_explosive_kick)