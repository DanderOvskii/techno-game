@tool

extends Node
@export var spawnpoints : Array[Node3D] = []
@export var spawnobjects : Array[PackedScene] = []
@export var spawnchange: Array[float] = []
@export var spawn_object_editor := false:
	set(value):
		spawn_object_editor = value
		if value:
			spawn_object_at_random_point()

var spawned_instance: Node3D

func _ready():
	spawn_object_at_random_point()
  



func pick_spawn_object() -> PackedScene:
	if spawnobjects.is_empty() or spawnchange.is_empty():
		push_warning("Spawn objects or spawnchange is empty!")
		return null

	if spawnobjects.size() != spawnchange.size():
		push_warning("spawnobjects and spawnchange have different sizes!")
		return spawnobjects[0]

	var total_prob = 0.0
	for prob in spawnchange:
		total_prob += prob
	
	var rand = randf() * total_prob
	var running_sum = 0.0
	
	for i in range(spawnobjects.size()):
		running_sum += spawnchange[i]
		if rand <= running_sum:
			return spawnobjects[i]
	
	return spawnobjects[0]

func spawn_object_at_random_point():
	if spawnpoints.is_empty():
		push_warning("No spawnpoints assigned!")
		return

	if spawned_instance and is_instance_valid(spawned_instance):
		spawned_instance.queue_free()
	for child in self.get_children(): child.queue_free()	
	var spawnpoint = spawnpoints[randi() % spawnpoints.size()]
	var object_to_spawn = pick_spawn_object()
	spawned_instance = object_to_spawn.instantiate()
	spawned_instance.position = spawnpoint.position
	spawned_instance.transform.origin = spawnpoint.transform.origin

	add_child(spawned_instance)

