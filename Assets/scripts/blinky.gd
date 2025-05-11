extends CharacterBody2D

var direction: Vector2 = Vector2.LEFT
var current_intersection: Intersection = null
var path: Array[Intersection] = []
var run_away_state : bool = false
var run_away_timer : float = 7.0

@export var intersection_group_name := "graph"
@export var tile_size := 8.0
@export var speed := 70.0
@onready var pacman: CharacterBody2D = $"../player"
@onready var debug: Node2D = $"../blinky_debug"
@onready var scoring: Node = $"../pellets"

func _ready():
	add_to_group("ghosts")
	
func _physics_process(delta):
	if global_position.distance_to(Vector2(152, 136)) < tile_size * 0.5 and not run_away_state:
		speed = 70.0
	if run_away_state:
		count_down(delta)
	velocity = direction * speed
	move_and_slide()

func set_current_intersection(inter: Intersection): #called by intersection signal
	if inter == current_intersection and not run_away_state:
		return
	current_intersection = inter

	# Snap to tile grid
	var snapped = inter.global_position.snapped(Vector2(tile_size, tile_size))
	global_position = snapped

	if run_away_state:
		direction = get_random_direction()
		current_intersection = null
		return
	elif current_intersection and pacman:
		direction = get_greedy_direction_to_position(pacman.global_position)
		#build_debug_greedy_path_to()

	
func get_greedy_direction_to_position(target_pos: Vector2) -> Vector2:
	if not current_intersection:
		return direction

	var best_dir: Vector2 = direction
	var best_score := INF

	for dir in current_intersection.neighbors.keys():
		if dir == -direction:
			continue

		var neighbor = current_intersection.neighbors[dir]["neighbor"]
		var score = calculate_heuristic(neighbor, target_pos) + current_intersection.neighbors[dir]["cost"]

		if score < best_score:
			best_score = score
			best_dir = dir

	return best_dir

func calculate_heuristic(neighbor: Intersection, target_pos: Vector2) -> float:
	return neighbor.global_position.distance_to(target_pos)

func run_away():
	if(run_away_state):
		run_away_timer = 7.0
		return
	run_away_state = true
	var texture = load("res://Assets/sprites/run_away.png")
	$Sprite2D.texture = texture
	if current_intersection and not global_position.distance_to(current_intersection.position) < tile_size * 0.5:
		direction = -direction
	speed = 35.0
	
func count_down(delta):
	run_away_timer -= delta
	if run_away_timer <= 0:
		run_away_state = false
		var texture = load("res://Assets/sprites/blinky.png")
		$Sprite2D.texture = texture
		run_away_timer = 7.0
		speed = 70.0

func get_random_direction() -> Vector2:
	if not current_intersection:
		return direction
	var directions : Array[Vector2]
	for dir in current_intersection.neighbors.keys():
		if dir == -direction:
			continue
		directions.append(dir)
	
	return directions.pick_random()

func build_debug_greedy_path_to():
	if not current_intersection or not pacman:
		return

	var graph = $"../graph"
	var intersections := graph.get_children().filter(func(n): return n is Intersection)

	var target_intersection: Intersection = null
	var min_distance := INF

	for inter in intersections:
		var dist = inter.global_position.distance_to(pacman.global_position)
		if dist < min_distance:
			min_distance = dist
			target_intersection = inter

	if not target_intersection:
		return

	var path: Array[Vector2] = []
	var visited := {}
	var current := current_intersection
	var prev_dir := direction

	while current and current != target_intersection:
		visited[current] = true
		path.append(current.global_position)

		var best_neighbor: Intersection = null
		var best_dir := Vector2.ZERO
		var best_score := INF

		for dir in current.neighbors.keys():
			if path.size() == 1 and dir == -prev_dir:
				continue  # Don't reverse on first move

			var neighbor = current.neighbors[dir]["neighbor"]
			var cost = current.neighbors[dir]["cost"]

			if neighbor in visited:
				continue

			var score = calculate_heuristic(neighbor, target_intersection.global_position) + cost
			if score < best_score:
				best_score = score
				best_neighbor = neighbor
				best_dir = dir

		if not best_neighbor:
			break

		prev_dir = best_dir
		current = best_neighbor

	if current == target_intersection:
		path.append(current.global_position)
		
	debug.set_debug_path(path, Color.RED)

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is player:
		if run_away_state:
			get_eaten()
		else:
			pacman.die()

func get_eaten():
	get_parent().get_tree().paused = true
	await get_tree().create_timer(0.6).timeout
	get_parent().get_tree().paused = false
	run_away_state = false
	var texture = load("res://Assets/sprites/blinky.png")
	$Sprite2D.texture = texture
	direction = Vector2.LEFT
	LifeManager.score += 1000
	scoring.score_board.set_text(str(LifeManager.score))
	self.position = Vector2(152, 136)
