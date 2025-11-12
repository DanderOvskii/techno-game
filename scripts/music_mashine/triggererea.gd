extends Area3D 

signal player_entered

@export var AreaId : int

func _ready():
	print("TriggerArea ready")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body:Node3D):
	if body.is_in_group("player"):  
		print("Player entered Trigger Area: %d" % AreaId)
		player_entered.emit(AreaId)
