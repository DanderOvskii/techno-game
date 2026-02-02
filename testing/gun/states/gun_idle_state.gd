extends GunState

func _on_idle_state_processing(delta):
    if not Gun_controller:
        return


    if Input.is_action_just_pressed("fire") and Gun_controller.can_fire():
        Gun_controller.gun_state_chart.send_event("fire")
        return

    if Gun_controller.current_ammo <=0:
        Gun_controller.gun_state_chart.send_event("no_ammo")
        return