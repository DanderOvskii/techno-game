extends CharacterBody3D

@export var SPEED = 6.5
const JUMP_VELOCITY = 4.5
@export var sensivity = 0.3

# FOV
@export var run_fov = 140.0
@export var normal_fov = 85.0
@export var fov_speed = 5.0
var target_fov = normal_fov

# Slide instellingen
@export var slide_speed: float = 14.0
@export var slide_duration: float = 0.6
@export var slide_height: float = 1.0  # hoogte tijdens slide
var is_sliding: bool = false
var slide_timer: float = 0.0
var original_collider_height: float
var slide_tilt = 0.0

# Kleine salto
var jump_count: int = 0       # Houdt bij hoeveel sprongen zijn uitgevoerd
@export var max_jumps: int = 2  # Max aantal sprongen
var saltoing: bool = false
var salto_timer: float = 0.0
@export var salto_duration: float = 0.6  # Hoe lang de salto duurt

# --- Bepaal slide tilt ---
@export var target_tilt = 0.0

# --- Bepaal link/rechts tilt ---
var movement_tilt = 0.0

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Onthoud originele capsule hoogte
	var capsule_shape = $CollisionShape3D.shape as CapsuleShape3D
	original_collider_height = capsule_shape.height


func _input(event):
	if event is InputEventMouseMotion:
		$Camera.rotation_degrees.x -= event.relative.y * sensivity
		$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * sensivity


func _physics_process(delta):
	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= gravity * delta
		# --- Reset jump count bij landen ---
	if is_on_floor():
		jump_count = 0
		
	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			# Eerste sprong normaal
			velocity.y = JUMP_VELOCITY
			jump_count = 1
		elif jump_count < max_jumps:
			# Tweede sprong: salto achteruit (alleen voor de sier)
			velocity.y = JUMP_VELOCITY  # vertical boost
			saltoing = true
			salto_timer = 0.0
			jump_count += 1

	# --- Run logic & FOV ---
	if Input.is_action_pressed("sprint"):
		target_fov = run_fov
		SPEED = 9.5
	else:
		target_fov = normal_fov
		SPEED = 7.5

	$Camera.fov = move_toward($Camera.fov, target_fov, fov_speed * 30 * delta)

	# --- Slide input ---
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and Input.is_action_pressed("sprint"):
		is_sliding = true
		slide_timer = 0.0
		
		# Verlaag collider hoogte
		var capsule_shape = $CollisionShape3D.shape as CapsuleShape3D
		capsule_shape.height = slide_height
		
		# Voorwaartse boost in kijkrichting
		var forward = -transform.basis.z
		velocity.x = forward.x * slide_speed
		velocity.z = forward.z * slide_speed
	

	# --- Slide timer en reset ---
	if is_sliding:
		slide_timer += delta
		# Smooth afremmen
		var slide_progress = slide_timer / slide_duration
		var current_speed = lerp(slide_speed, 4.7, slide_progress)

		var forward = -transform.basis.z
		velocity.x = forward.x * current_speed
		velocity.z = forward.z * current_speed

		if slide_timer >= slide_duration:
			is_sliding = false
			var capsule_shape = $CollisionShape3D.shape as CapsuleShape3D
			capsule_shape.height = original_collider_height

	# --- Movement ---
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and not is_sliding:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	elif not is_sliding:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# --- Camera tilt ---
	var movement_tilt = 0.0
	if not is_sliding:
		movement_tilt = input_dir.x * 5.0  # max 5 graden naar links/rechts

	if is_sliding:
		target_tilt = -12.0   # slide tilt
	else:
		target_tilt = movement_tilt

	slide_tilt = lerp(slide_tilt, target_tilt, delta * 8)
	$Camera.rotation_degrees.z = slide_tilt
	
	# --- Salto update ---
	if saltoing:
		salto_timer += delta
		var progress = salto_timer / salto_duration
		if progress > 1.0:
			progress = 1.0
			saltoing = false
		var salto_angle = lerp(0.0, 360.0, progress)  # volledige salto
		$Camera.rotation_degrees.z = salto_angle
	
	move_and_slide()



func _on_area_3d_body_entered(body):
	if body.name=="player":
		get_tree().change_scene_to_file("res://node_3d.tscn")
