extends CharacterBody3D
@onready var camera = $Camera
@onready var camera_original_height:float = camera.transform.origin.y
@onready var capsule = $walkCollision as CollisionShape3D 
@onready var capsule_shape = capsule.shape as CapsuleShape3D
@onready var original_capsule_shap_height = capsule_shape.height
@onready var slide_move_height: float = (original_capsule_shap_height - slide_height) / 2
@onready var original_slider_cooldown: float = slide_cooldown

@export_group("Character Speeds")
@export var JUMP_VELOCITY: float = 4.5
@export_range(1.0,20.0) var tilt_speed: float = 10.0
@export_range(1.0,20.0) var fov_speed: float = 10.0

@export_group("walk-run")
@export var SPEED: float = 4
@export var normal_fov: float = 100.0
@export var runSpeed: float = 9.5
@export var run_fov: float = 120.0
@export_range(1.0,10.0) var transition_speed: float = 6.0
@export_range(1.0,45.0) var tilt_amount: float = 5.0

@export_group("sliding")
@export var slide_speed: float = 16.0
@export var slide_lerp_speed: float = 10.0  
@export var slide_duration: float = 2.0
@export var slide_height: float = 1.0  
@export var slide_cooldown: float = 0.2
@export_range(-45.0,45.0,1.0) var slide_tilt:float = -12.0
@export_range(0.0,1.0)var slide_steering:float=0.4

@export_group("Character Settings")
@export var max_jumps: int = 2  # Max aantal sprongen
@export var salto_duration: float = 0.6  # Hoe lang de salto duurt
@export var gun: Node3D


@export_group("Controls")
@export_range(0.1,1) var sensivity: float = 0.3
@export var LEFT : String = "left"
@export var RIGHT : String = "right"
@export var UP : String = "up"
@export var DOWN : String = "down"
@export var SPRINT : String = "sprint"
@export var SLIDE : String = "ui_accept"

var is_sliding: bool = false
var slide_timer: float = 0.0


var jump_count: int = 0  
var saltoing: bool = false
var salto_timer: float = 0.0


var target_fov = normal_fov
var target_tilt = 0.0
var target_speed: float
var slide_direction: Vector3 = Vector3.ZERO

var current_speed: float
var movement_tilt = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_height_target: float



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	camera_height_target = camera_original_height


func _input(event):
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= event.relative.y * sensivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * sensivity


func _physics_process(delta):
	current_speed = move_toward(current_speed,target_speed, transition_speed*10*delta)
	movement_tilt = lerp(movement_tilt, target_tilt, delta * tilt_speed)
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		jump_count = 0
	run()
	jump(delta)
	



	camera.fov = move_toward(camera.fov, target_fov, fov_speed *10* delta)

	
	slide(delta)

	var input_dir = Input.get_vector(LEFT, RIGHT, UP, DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and not is_sliding:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	elif not is_sliding:
		target_speed = 0.0
		velocity.x = move_toward(velocity.x, 0, transition_speed *10* delta)
		velocity.z =  move_toward(velocity.z, 0, transition_speed *10* delta)
	if not is_sliding:
		target_tilt = input_dir.x * tilt_amount
	
	camera.rotation_degrees.z = movement_tilt
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
			salto(delta)


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
	var slide_progress = slide_timer / slide_duration
	var current_slide_speed = lerp(slide_speed, 0.0, slide_progress)
	camera.position.y = lerp(camera.position.y, camera_height_target, delta * slide_lerp_speed)
	slide_cooldown = move_toward(slide_cooldown, 0.0, delta)

	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and Input.is_action_pressed("sprint") and slide_cooldown<= 0.0:
		target_tilt = slide_tilt
		is_sliding = true
		slide_timer = 0.0
		capsule.position.y = -slide_move_height
		capsule_shape.height = capsule_shape.height - slide_height
		camera_height_target = camera_original_height - slide_move_height
		var player_forward = -transform.basis.z
		player_forward.y = 0
		slide_direction= player_forward
		

	if is_sliding:
		slide_timer += delta
		var cam_forward = -camera.global_transform.basis.z
		cam_forward.y = 0
		cam_forward = cam_forward.normalized()


		var slide_dir = (slide_direction.lerp(cam_forward,slide_steering)).normalized()

		velocity.x = slide_dir.x * current_slide_speed
		velocity.z = slide_dir.z * current_slide_speed

		if slide_timer >= slide_duration or Input.is_action_just_released("slide"):
			is_sliding = false
			target_tilt = 0.0
			capsule.position.y = 0.0
			capsule_shape.height = capsule_shape.height + slide_height
			camera_height_target = camera_original_height
			current_speed = current_slide_speed
			slide_cooldown = original_slider_cooldown

func run():
	if Input.is_action_pressed(SPRINT):
		target_fov = run_fov
		target_speed = runSpeed
	else:
		target_fov = normal_fov
		target_speed = SPEED  # Replace with function body.



func _on_area_3d_body_entered(body):
	if body.name=="player":
		get_tree().change_scene_to_file("res://node_3d.tscn")
