static func apply_world_curvature(pos: Vector3, camera_pos: Vector3, curvature_strength: float) -> Vector3:
    var diff = Vector2(pos.x, pos.z) - Vector2(camera_pos.x, camera_pos.z)
    var dist = diff.length()

    pos.y += dist * dist * curvature_strength
    return pos

static func unapply_world_curvature(pos: Vector3, camera_pos: Vector3, curvature_strength: float) -> Vector3:
    var diff = Vector2(pos.x, pos.z) - Vector2(camera_pos.x, camera_pos.z)
    var dist = diff.length()
    pos.y -= dist * dist * curvature_strength
    return pos