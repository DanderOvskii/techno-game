extends Control

# Volume slider veranderingsfunctie
func _on_volume_slider_value_changed(value):
	GameSettings.master_volume = value
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(GameSettings.master_volume)
	)

# Brightness slider veranderingsfunctie
func _on_brightness_slider_value_changed(value):
	GameSettings.brightness = value


func _ready():
	# Zet sliders naar huidige waarden
	$VolumeSlider.value = GameSettings.master_volume
	
	if $BrightnessSlider:
		$BrightnessSlider.value = GameSettings.brightness


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
