extends GunState

func _on_fire_state_entered():
    if not Gun_controller:
        return

    Gun_controller.fire_gun()

func _on_fire_state_physics_processing(delta):
    if not Gun_controller:
        return

    if Gun_controller.current_ammo <= 0:
        Gun_controller.gun_state_chart.send_event("no_ammo")
        return
    Gun_controller.gun_state_chart.send_event("idle")