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

var gun_instance: Node3D
var current_ammo: int

func _ready():
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
        print("Hit: %s" % result.collider.name)
        _spawn_impact_effect(result.position)


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