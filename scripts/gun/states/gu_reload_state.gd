extends GunState

func _on_reload_state_entered():
    if not Gun_controller:
        return

    Gun_controller.reload_gun()

func _on_reload_state_physics_processing(delta):
    if not Gun_controller:
        return

    Gun_controller.gun_state_chart.send_event("onIdle")

