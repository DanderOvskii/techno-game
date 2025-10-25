@tool
extends DungeonRoom3D
# 🔹 Drag and drop your room scenes in the editor inspector:
@export var room_straight: PackedScene
@export var room_corner: PackedScene
@export var room_tjunction: PackedScene
@export var room_cross: PackedScene
@export var room_deadend_front: PackedScene
@export var room_deadend_back: PackedScene
@export var room_deadend_left: PackedScene
@export var room_deadend_right: PackedScene
@export var room_empty: PackedScene

func _ready():
	super._ready()
	dungeon_done_generating.connect(replace_room_based_on_connections)


func replace_room_based_on_connections():
	var connected_dirs = []

	# Check each direction for a connected door
	if get_door_by_node($"CSGBox3D/DOOR?_F_CUT").get_room_leads_to() != null:
		connected_dirs.append("F")
	if get_door_by_node($"CSGBox3D/DOOR?_B_CUT").get_room_leads_to() != null:
		connected_dirs.append("B")
	if get_door_by_node($"CSGBox3D/DOOR?_R_CUT").get_room_leads_to() != null:
		connected_dirs.append("R")
	if get_door_by_node($"CSGBox3D/DOOR?_L_CUT").get_room_leads_to() != null:
		connected_dirs.append("L")

	connected_dirs.sort()

	var new_room: PackedScene = null
	var rotation_y := 0.0 

	# Decide which room type fits this connection pattern
	match connected_dirs:
	# Straight corridors
		["B", "F"]:
			new_room = room_straight
			rotation_y = deg_to_rad(90)
		["L", "R"]:
			new_room = room_straight
			rotation_y = deg_to_rad(0)

	# Corners (turns)
		["F", "R"]:
			new_room = room_corner
			rotation_y = deg_to_rad(90)
			
		["B", "R"]:
			new_room = room_corner
			rotation_y = deg_to_rad(0)
			
		["B", "L"]:
			new_room = room_corner
			rotation_y = deg_to_rad(270)
			
		["F", "L"]:
			new_room = room_corner
			rotation_y = deg_to_rad(180)
			
		#t sections
		["B", "F", "L"]:
			new_room = room_tjunction
			rotation_y = deg_to_rad(0)
			
		["B", "F", "R"]:
			new_room = room_tjunction
			rotation_y = deg_to_rad(180)
			
		["B", "L", "R"]:
			new_room = room_tjunction
			rotation_y = deg_to_rad(90)	
			
		["F", "L", "R"]:
			new_room = room_tjunction
			rotation_y = deg_to_rad(270)	
		# Default (no connections)
		_:
			new_room = room_empty

	if new_room != null:
		_replace_room(new_room, rotation_y)


func _replace_room(scene: PackedScene, rotation_y: float):
	var new_room_instance = scene.instantiate()
	new_room_instance.global_transform = global_transform
	new_room_instance.rotate_y(rotation_y)
	var parent = get_parent()
	parent.add_child(new_room_instance)
	queue_free()
