@tool

extends Camera3D  # or Camera3D if you put it on the camera

@export var woldcurf_shader_path: String = "res://shaders/worldcurf_shader.shader"	
@export_range(-0.02,0.02,0.001) var curvature_strength: float = 0.0

@onready var materials := []  # we'll fill this later

func _ready():
	_find_curved_materials(get_tree().get_root())
	_set_curvature_strength(curvature_strength)
func _process(_delta):
	var cam_pos = global_position
	for mat in materials:
		mat.set_shader_parameter("camera_position", cam_pos)

func _find_curved_materials(node):
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
		_find_curved_materials(child)


func _set_curvature_strength(value: float):
	curvature_strength = value
	for mat in materials:
		mat.set_shader_parameter("curvature_strength", curvature_strength)