@tool
extends Node3D
class_name GunController
@export var camera_node: Camera3D

@export var gun_recource: GunRecorce:
    set(value):
        gun_recource = value
        if Engine.is_editor_hint():
            instance_gun()

@export var gun_parrent: Node3D

var gun_instance: Node3D

func _ready():
    if camera_node == null:
        camera_node = get_viewport().get_camera_3d()
    if gun_recource and not Engine.is_editor_hint():
        instance_gun()
    

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