# get all the materials that need a world curvature 
# and apply the global curvature strength to them, 
# also update the camera position in the shader every frame

extends Camera3D  

@export var woldcurf_shader_path: String = "res://shaders/worldcurf_shader.shader"	
var curvature_strength: float = GlobalVars.curvature_strength

@onready var materials := []  

func _ready():
	_find_curved_materials(get_tree().get_root())
	_set_curvature_strength(curvature_strength)
	
func _process(_delta):
	var cam_pos = global_position
	GlobalVars.camera_position = cam_pos
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
				materials.append(mat)
	for child in node.get_children():
		_find_curved_materials(child)


func _set_curvature_strength(value: float):
	curvature_strength = value
	for mat in materials:
		mat.set_shader_parameter("curvature_strength", curvature_strength)
