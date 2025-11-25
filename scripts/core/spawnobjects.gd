@tool

extends Node
@export var spawnpoints : Array[Node3D] = []
@export var spawnobjects : Array[PackedScene] = []
@export var spawnchange: Array[float] = []
@export var spawn_object_editor : bool = false :
    set(value):
        spawn_object_at_random_point()

func _ready():
    spawn_object_at_random_point()
  



func pick_spawn_object() -> PackedScene:
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
    for child in self.get_children():
        child.queue_free()
    var spawnpoint = spawnpoints[randi() % spawnpoints.size()]
    var object_to_spawn = pick_spawn_object()
    var instance = object_to_spawn.instantiate()
    instance.position = spawnpoint.position
    instance.transform.origin = spawnpoint.transform.origin

    add_child(instance)