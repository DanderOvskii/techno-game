extends GunState

func _on_empty_state_entered():
    print("Enterd  empty")

    Gun_controller.fire_gun()

func _on_empty_state_processing(delta):
    pass