extends Node2D

@export var tile_size := 16.0

func _ready():
	var intersections = get_children().filter(func(n): return n is Intersection)
	var wall_map: TileMap = $"../level"

	for intersection in intersections:
		for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var neighbor = find_neighbor(intersection, direction, intersections, wall_map)
			if neighbor:
				var cost = intersection.global_position.distance_to(neighbor.global_position)
				intersection.add_neighbor(direction, neighbor, cost)

func find_neighbor(origin: Intersection, direction: Vector2, intersections: Array, wall_map: TileMap) -> Intersection:
	var step = tile_size
	var origin_pos = origin.global_position
	var current_pos = origin_pos + direction * step
	var max_distance = step * 20

	while origin_pos.distance_to(current_pos) <= max_distance:
		var cell = wall_map.local_to_map(wall_map.to_local(current_pos))
		if wall_map.get_cell_source_id(0, cell) != -1:
			return null

		for inter in intersections:
			if inter == origin:
				continue
			if inter.global_position.distance_to(current_pos) < step * 0.4:
				return inter

		current_pos += direction * step

	return null
