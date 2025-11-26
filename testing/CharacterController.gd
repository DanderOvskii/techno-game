extends CharacterBody3D

@export_group("Character Speeds")
@export var SPEED: float = 6.5
@export var slide_speed: float = 14.0
@export var slide_lerp_speed := 10.0  
@export var JUMP_VELOCITY: float = 4.5

@export_group("Character Settings")
@export var max_jumps: int = 2  # Max aantal sprongen
@export var salto_duration: float = 0.6  # Hoe lang de salto duurt
@export var run_fov: float = 140.0
@export var normal_fov: float = 85.0
@export var fov_speed: float = 5.0
@export var slide_duration: float = 0.6
@export var slide_height: float = 1.0  


@export_group("Controls")
@export var sensivity: float = 0.3
@export var LEFT : String = "left"
@export var RIGHT : String = "right"
@export var UP : String = "up"
@export var DOWN : String = "down"
@export var SPRINT : String = "sprint"
@export var SLIDE : String = "ui_accept"

var is_sliding: bool = false
var slide_timer: float = 0.0
var slide_tilt = 0.0


var jump_count: int = 0  
var saltoing: bool = false
var salto_timer: float = 0.0


var target_fov = normal_fov
var target_tilt = 0.0
var movement_tilt = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_original_height:float
var camera_height_target: float
@onready var camera = $Camera
@onready var capsule_shape = $walkCollision as CollisionShape3D 
@onready var slide_capsule_shape = $slideCollision as CollisionShape3D 


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	capsule_shape.disabled = false
	slide_capsule_shape.disabled = true
	camera_original_height = camera.transform.origin.y
	camera_height_target = camera_original_height


func _input(event):
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= event.relative.y * sensivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * sensivity


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		jump_count = 0
		
	jump(delta)
	salto(delta)

	if Input.is_action_pressed(SPRINT):
		target_fov = run_fov
		SPEED = 9.5
	else:
		target_fov = normal_fov
		SPEED = 7.5

	camera.fov = move_toward(camera.fov, target_fov, fov_speed * 30 * delta)

	
	slide(delta)

	var input_dir = Input.get_vector(LEFT, RIGHT, UP, DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and not is_sliding:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	elif not is_sliding:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if not is_sliding:
		movement_tilt = input_dir.x * 5.0
	
	
	move_and_slide()

func jump(delta):
	if Input.is_action_just_pressed(SLIDE) and !is_sliding:
		if is_on_floor():
			# Eerste sprong normaal
			velocity.y = JUMP_VELOCITY
			jump_count = 1
		elif jump_count < max_jumps:
			# Tweede sprong: salto achteruit (alleen voor de sier)
			velocity.y = JUMP_VELOCITY  # vertical boost
			salto_timer = 0.0
			saltoing = true
			jump_count += 1


func salto(delta):
	if saltoing:
		salto_timer += delta
		var progress = salto_timer / salto_duration
		if progress > 1.0:
			progress = 1.0
			saltoing = false
		var salto_angle = lerp(0.0, 360.0, progress)  # volledige salto
		camera.rotation_degrees.z = salto_angle

func slide(delta):
	var forward = -transform.basis.z
	var slide_progress = slide_timer / slide_duration
	var current_speed = lerp(slide_speed, 10.0, slide_progress)
	camera.position.y = lerp(camera.position.y, camera_height_target, delta * slide_lerp_speed)

	slide_tilt = lerp(slide_tilt, target_tilt, delta * 8)

	camera.rotation_degrees.z = slide_tilt

	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and Input.is_action_pressed("sprint"):
		is_sliding = true
		slide_timer = 0.0
		velocity.x = forward.x * slide_speed
		velocity.z = forward.z * slide_speed
		velocity.y = -5.0
		target_tilt = -12.0
		capsule_shape.disabled = true
		slide_capsule_shape.disabled = false
		camera_height_target = camera_original_height - slide_height
		

	if is_sliding:
		slide_timer += delta
		velocity.x = forward.x * current_speed
		velocity.z = forward.z * current_speed

		if slide_timer >= slide_duration or Input.is_action_just_released("slide"):
			is_sliding = false
			target_tilt = movement_tilt
			capsule_shape.disabled = false
			slide_capsule_shape.disabled = true
			camera_height_target = camera_original_height

	



func _on_area_3d_body_entered(body):
	if body.name=="player":
		get_tree().change_scene_to_file("res://node_3d.tscn")
