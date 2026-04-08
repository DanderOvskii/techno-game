extends Node3D

@export var camera: Node3D
@export var source_mesh_instance: MeshInstance3D
@export var collision_radius: float = 25.0
@export var update_interval: float = 0.25
@export var movement_threshold: float = 3.0

@onready var curvature_strength: float = GlobalVars.curvature_strength

var ghost_body: StaticBody3D
var collision_shape: CollisionShape3D

var last_cam_pos := Vector3.ZERO
var update_timer := 0.0

# Thread state
var thread: Thread = null
var build_in_progress := false

# Cached snapshot for thread safety
var cached_mesh: Mesh
var cached_cam_pos: Vector3


func _ready():
    if camera == null:
        camera = get_viewport().get_camera_3d()

    create_ghost()
    last_cam_pos = camera.global_position


func create_ghost():
    ghost_body = StaticBody3D.new()
    ghost_body.name = "GhostCollision"
    add_child(ghost_body)

    collision_shape = CollisionShape3D.new()
    ghost_body.add_child(collision_shape)

    ghost_body.collision_layer = 2
    ghost_body.collision_mask = 0


func _process(delta):
    update_timer += delta
    if update_timer < update_interval:
        return
    update_timer = 0.0

    var cam_pos = camera.global_position

    if cam_pos.distance_to(last_cam_pos) < movement_threshold:
        return

    last_cam_pos = cam_pos
    request_build(cam_pos)


# ---------------------------
# REQUEST BUILD
# ---------------------------
func request_build(cam_pos: Vector3):
    if build_in_progress:
        return

    build_in_progress = true

    cached_mesh = source_mesh_instance.mesh
    cached_cam_pos = cam_pos

    thread = Thread.new()
    thread.start(Callable(self, "_build_thread"))


# ---------------------------
# THREAD WORKER
# ---------------------------
func _build_thread():
    var mesh = cached_mesh
    if mesh == null:
        call_deferred("_finish_build", null)
        return

    var player_pos = cached_cam_pos

    var new_vertices := PackedVector3Array()
    var new_indices := PackedInt32Array()

    var global_transform = source_mesh_instance.global_transform
    var inv_transform = global_transform.affine_inverse()

    for surface in range(mesh.get_surface_count()):
        var arrays = mesh.surface_get_arrays(surface)
        var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
        var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

        if vertices.is_empty() or indices.is_empty():
            continue

        new_vertices.clear()
        new_indices.clear()

        for i in range(0, indices.size(), 3):
            var i0 = indices[i]
            var i1 = indices[i + 1]
            var i2 = indices[i + 2]

            var w0 = global_transform * vertices[i0]
            var w1 = global_transform * vertices[i1]
            var w2 = global_transform * vertices[i2]

            var center = (w0 + w1 + w2) * 0.3333

            if center.distance_to(player_pos) > collision_radius:
                continue

            w0 = _curve(w0, player_pos)
            w1 = _curve(w1, player_pos)
            w2 = _curve(w2, player_pos)

            var base = new_vertices.size()

            new_vertices.append(inv_transform * w0)
            new_vertices.append(inv_transform * w1)
            new_vertices.append(inv_transform * w2)

            new_indices.append(base)
            new_indices.append(base + 1)
            new_indices.append(base + 2)

        break  # optional early exit

    var mesh_out = ArrayMesh.new()

    if new_vertices.size() > 0:
        var arr = []
        arr.resize(Mesh.ARRAY_MAX)
        arr[Mesh.ARRAY_VERTEX] = new_vertices
        arr[Mesh.ARRAY_INDEX] = new_indices

        mesh_out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

    call_deferred("_finish_build", mesh_out)


# ---------------------------
# APPLY RESULT (MAIN THREAD)
# ---------------------------
func _finish_build(mesh_out):
    if mesh_out != null:
        collision_shape.shape = mesh_out.create_trimesh_shape()

    build_in_progress = false


# ---------------------------
# CURVATURE
# ---------------------------
func _curve(world_pos: Vector3, player_pos: Vector3) -> Vector3:
    var dx = world_pos.x - player_pos.x
    var dz = world_pos.z - player_pos.z
    var dist_sq = dx * dx + dz * dz

    world_pos.y += dist_sq * curvature_strength
    return world_pos