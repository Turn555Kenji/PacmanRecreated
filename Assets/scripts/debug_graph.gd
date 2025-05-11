extends Node2D

var path: Array[Vector2] = []
var ghost_color = Color.YELLOW

func set_debug_path(world_positions: Array[Vector2], color: Color):
	ghost_color = color
	path = world_positions.duplicate()
	queue_redraw()

func _draw():
	if path.size() < 2:
		return

	for i in range(path.size() - 1):
		draw_line(path[i], path[i + 1], ghost_color, 2.0)
