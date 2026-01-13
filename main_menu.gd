extends Control

@onready var pause = $"."
@onready var animation_player = $AnimationPlayer
var paused = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pausemenu()



func _on_resume_pressed() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.hide()
	get_tree().paused = false
	paused = false

func _on_options_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://options.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func pausemenu():
	
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.hide()
		get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		self.show()
		animation_player.play("open")
		get_tree().paused = true
	paused = !paused  # Flip the paused state
