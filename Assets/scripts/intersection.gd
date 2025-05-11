class_name Intersection
extends Node2D

var debug = false
var neighbors = {} # # direction: { neighbor: Intersection, cost: float }
	
# Debug functions to visualize graph, remove comment marks to show

#func _process(float) -> void:
#	if debug:
#		queue_redraw() #Calls _draw()
	

#func _draw():
#	if debug:
#		for entry in neighbors.values():
#			var neighbor = entry["neighbor"]
#			draw_line(Vector2.ZERO, neighbor.global_position - global_position, Color.RED, 2)

#

func add_neighbor(direction: Vector2, neighbor: Intersection, cost: float):
	neighbors[direction] = {
		"neighbor": neighbor,
		"cost": cost
	}

func _on_area_2d_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("ghosts"):
		parent.set_current_intersection(self)
