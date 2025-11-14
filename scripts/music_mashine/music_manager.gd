# res://globals/BeatManager.gd
extends Node

signal beat(index: int)

@export var bpm: float = 160.0: set = _set_bpm
@export var timing: int = 4: set = _set_timing # optional subdivisions per beat

@onready var materials := [] 

var beat_length := 0.0
var time_accumulator := 0.0
var global_index := 0
var is_playing := true

func _ready():
	_find_animated_textures(get_tree().get_root())
	_set_bpm(bpm)
	_update_beat_length()

func _process(delta):
	if not is_playing:
		return

	time_accumulator += delta
	if time_accumulator >= beat_length:
		time_accumulator -= beat_length
		emit_signal("beat", global_index)
		global_index += 1

func _set_bpm(value):
	bpm = value
	for mat in materials:
		mat.set_shader_parameter("bpm", bpm)
	_update_beat_length()

func _set_timing(value):
	timing = value
	_update_beat_length()

func _update_beat_length():
	beat_length = 60.0 / bpm
	if timing > 1:
		beat_length /= timing


func pause():
	is_playing = false

func resume():
	is_playing = true

func reset():
	global_index = 0

func _find_animated_textures(node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if !mesh:
			return
		for i in range(mesh.get_surface_count()):
			var mat = node.get_active_material(i)
			if mat is ShaderMaterial:
				# Optionally: check for a specific shader name/path
				materials.append(mat)
	for child in node.get_children():
		_find_animated_textures(child)
