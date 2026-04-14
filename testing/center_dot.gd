extends CenterContainer

@export var DORT_RADIUS: float = 10.0
@export var DORT_COLOR: Color = Color.RED

func _ready():
    pass

func _draw():
    draw_circle(Vector2.ZERO, DORT_RADIUS, DORT_COLOR)
