extends CharacterBody3D


@export var  SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var sensivity = 0.3
@export var run_fov = 110.0
@export var normal_fov = 85.0
@export var fov_speed = 5.0  # Adjust for smoother or faster transition
var fov = false
var lerp_speed= 1
var target_fov = normal_fov


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event):
	if event is InputEventMouseMotion:
		$Camera.rotation_degrees.x -= event.relative.y * sensivity
		$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * sensivity

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
# Run logic
	if Input.is_action_pressed("sprint"):
		target_fov = run_fov
		SPEED = 7.0
	else:
		target_fov = normal_fov
		SPEED = 5.0

	# Smoothly interpolate the FOV
	$Camera.fov = lerp($Camera.fov, target_fov, fov_speed * delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_area_3d_body_entered(body):
	if body.name=="player":
		get_tree().change_scene_to_file("res://node_3d.tscn")

	pass # Replace with function body.
