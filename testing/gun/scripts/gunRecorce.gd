extends Resource
class_name GunRecorce

@export var gun_name: String = ""
@export var gun_scene: PackedScene
@export var projectile_scene: PackedScene
@export var damage: int 
@export var is_hitscan:bool = true
@export var shoot_range:float = 50.0
@export var ammo_capacity: int = 99
@export var fire_rate: float
@export var weapon_position: Vector3 = Vector3(0.2, -0.2, -0.3)
