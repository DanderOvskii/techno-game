extends Node

#calculate the cuveture based on camera distance and strength
func apply_world_curvature(pos: Vector3) -> Vector3:
    var curvature_strength: float = GlobalVars.curvature_strength
    var camera_pos = GlobalVars.camera_position
    var diff = Vector2(pos.x, pos.z) - Vector2(camera_pos.x, camera_pos.z)
    var dist = diff.length()

    pos.y += dist * dist * curvature_strength
    return pos

#reverse the calculated curvature to get the real position
func unapply_world_curvature(pos: Vector3) -> Vector3:
    var curvature_strength: float = GlobalVars.curvature_strength
    var camera_pos = GlobalVars.camera_position
    var diff = Vector2(pos.x, pos.z) - Vector2(camera_pos.x, camera_pos.z)
    var dist = diff.length()
    pos.y -= dist * dist * curvature_strength
    return pos