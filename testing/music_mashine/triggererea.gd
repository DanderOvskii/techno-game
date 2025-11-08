extends Area3D 

signal player_entered

func _ready():
	print("TriggerArea ready")
	body_entered.connect(self._on_body_entered)


func _on_body_entered(body:Node3D):
	print("Body entered: ", body.name)
	if body.is_in_group("player"):  
		player_entered.emit()
