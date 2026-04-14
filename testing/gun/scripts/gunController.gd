@tool
class_name GunController
extends Node3D
@export var camera_node: Camera3D

@export var gun_recource: GunRecorce:
    set(value):
        gun_recource = value
        if Engine.is_editor_hint():
            instance_gun()

@export var gun_parrent: Node3D
@export var gun_state_chart: StateChart
@onready var curvature_strength: float = GlobalVars.curvature_strength

var debug_mesh_instance : MeshInstance3D
var debug_mesh : ImmediateMesh


var gun_instance: Node3D
var current_ammo: int

func _ready():
    debug_mesh = ImmediateMesh.new()
    debug_mesh_instance = MeshInstance3D.new()
    debug_mesh_instance.mesh = debug_mesh
    # No lighting, just pure color
    var mat = ORMMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.vertex_color_use_as_albedo = true
    debug_mesh_instance.material_override = mat
    get_tree().current_scene.add_child.call_deferred(debug_mesh_instance)
  



    if camera_node == null:
        camera_node = get_viewport().get_camera_3d()
    if gun_recource and not Engine.is_editor_hint():
        instance_gun()
        current_ammo = gun_recource.ammo_capacity
    

func attack():   
    var space_state = camera_node.get_world_3d().direct_space_state
    var screen_cenetr = get_viewport().size /2
    print(screen_cenetr)

func instance_gun():
    if gun_instance:
        gun_instance.queue_free()
    if gun_recource and gun_recource.gun_scene and gun_parrent:
        gun_instance = gun_recource.gun_scene.instantiate() as Node3D
        gun_parrent.add_child(gun_instance)
        if Engine.is_editor_hint():
            gun_instance.owner = get_tree().edited_scene_root
        gun_instance.position = gun_recource.weapon_position
    print("gun instanced")


func can_attack()->bool:
    return current_ammo > 0
    

func fire_gun()->void:
    if can_attack():
        current_ammo -= 1
        print("Fired! Ammo left: %d" % current_ammo)
        if gun_recource.is_hitscan:
            _preform_hitscan()


func reload_gun():
    current_ammo = gun_recource.ammo_capacity
    print("Reloaded! Ammo refilled to: %d" % current_ammo)


func _preform_hitscan():
    if not camera_node:
        return
    var space_state = camera_node.get_world_3d().direct_space_state
    var from = camera_node.global_position
    var forward = -camera_node.global_transform.basis.z
    var to = from + forward * gun_recource.shoot_range

    var quert = PhysicsRayQueryParameters3D.create(from, to)
    quert.collision_mask = 2
    var result = space_state.intersect_ray(quert)

    if result:
        if _is_target_reachable_curved(result.position):
            print("Hit confirmed: %s" % result.collider.name)
            _spawn_impact_effect(result.position)
        else:
            print("Hit blocked by geometry (curved path check failed)")


func _world_to_physics_pos(visual_pos: Vector3) -> Vector3:
    # Reverse the shader's curvature to get the real physics position
    # var diff = visual_pos.xz - camera_node.global_position.xz  # Vector2
    # Wait — xz gives a Vector2 implicitly in some contexts, so be explicit:
    var diff2 = Vector2(visual_pos.x - camera_node.global_position.x,
                        visual_pos.z - camera_node.global_position.z)
    var dist = diff2.length()
    var y_offset = dist * dist * curvature_strength
    return Vector3(visual_pos.x, visual_pos.y - y_offset, visual_pos.z)


func _is_target_reachable_curved(target_visual_pos: Vector3, steps: int = 50) -> bool:
    var from_visual = camera_node.global_position  # Camera isn't curved
    var forward = -camera_node.global_transform.basis.z

    # We march from the camera toward the visual hit point in steps
    var total_dist = from_visual.distance_to(target_visual_pos)
    var prev_physics = _world_to_physics_pos(from_visual)

    var space_state = camera_node.get_world_3d().direct_space_state
    debug_mesh.clear_surfaces()

    var excluded = []
    for enemy in get_tree().get_nodes_in_group("enemy"):
        for col in enemy.find_children("*", "CollisionObject3D", true, false):
            excluded.append(col.get_rid())

    for i in range(1, steps + 1):
        var t = float(i) / float(steps)

        # Linear interpolation in visual space along the shot direction
        var visual_point = from_visual + forward * (total_dist * t)
        var physics_point = _world_to_physics_pos(visual_point)

        # Cast a short segment between the two physics positions
        var query = PhysicsRayQueryParameters3D.create(prev_physics, physics_point)
        query.collision_mask = 1  # World geometry layer, NOT the enemy collider layer
        query.exclude = excluded
        var result = space_state.intersect_ray(query)

        if result:
            _debug_draw_line(prev_physics, result.position, Color.RED)
            return false  # Something blocked the path in real space
        else:
            _debug_draw_line(prev_physics, physics_point, Color.GREEN)

        prev_physics = physics_point

    return true

func _spawn_impact_effect(position: Vector3):
    var marker = MeshInstance3D.new()
    var box = BoxMesh.new()
    marker.scale = Vector3(0.1, 0.1, 0.1)
    marker.mesh = box

    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED
    marker.set_surface_override_material(0,material)

    get_tree().current_scene.add_child(marker)
    marker.global_position = position

    get_tree().create_timer(2.0).timeout.connect(marker.queue_free)


func _debug_draw_line(from: Vector3, to: Vector3, color: Color):
    debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    debug_mesh.surface_set_color(color)
    debug_mesh.surface_add_vertex(from)
    debug_mesh.surface_set_color(color)
    debug_mesh.surface_add_vertex(to)
    debug_mesh.surface_end()
