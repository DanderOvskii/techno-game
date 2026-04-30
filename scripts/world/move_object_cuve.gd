extends Node3D

var original_world_pos: Vector3

func _ready():
	original_world_pos = global_position
	

func _process(delta):
	
	var curved_position = GlobalFuncs.apply_world_curvature(original_world_pos)
	global_position = curved_position
