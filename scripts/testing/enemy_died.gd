extends Node


func _on_health_component_died() -> void:
	print(name,"destroid")
	queue_free()
