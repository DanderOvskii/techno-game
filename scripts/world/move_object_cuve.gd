extends Node3D  # or whatever node type your object is

# Reference to the camera to get camera_position
@export var camera_node: Camera3D

var original_world_pos: Vector3
var curvature_strength: float = GlobalVars.curvature_strength

func _ready():
    # Store the original world position
    original_world_pos = global_position
    
    # If no camera is assigned, try to find the main camera
    if camera_node == null:
        camera_node = get_viewport().get_camera_3d()

func _process(delta):
    if camera_node == null:
        return
    
    # Apply world curvature similar to your shader
    var curved_position = apply_world_curvature(original_world_pos, camera_node.global_position)
    global_position = curved_position

func apply_world_curvature(world_pos: Vector3, camera_pos: Vector3) -> Vector3:
    var diff = Vector2(world_pos.x - camera_pos.x, world_pos.z - camera_pos.z)
    var dist = diff.length()
    world_pos.y += dist * dist * curvature_strength
    return world_pos