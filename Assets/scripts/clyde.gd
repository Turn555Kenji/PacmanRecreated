extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var current_intersection: Intersection = null
var path: Array[Intersection] = []
var run_away_state: bool = false
var run_away_timer : float = 7.0
var house_timer : float = 22.0

@export var intersection_group_name := "graph"
@export var tile_size := 8.0
@export var speed := 70.0
@export var scatter_corner_pos: Vector2 = Vector2(30, 327)

@onready var pacman: CharacterBody2D = $"../player"
@onready var debug: Node2D = $"../clyde_debug"
@onready var graph: Node2D = $"../graph"
@onready var scoring: Node = $"../pellets"


func _ready():
	add_to_group("ghosts")
	
func _physics_process(delta):
	
	if global_position.distance_to(Vector2(152, 136)) < tile_size * 0.5 and not run_away_state:
		speed = 70.0
	if house_timer >= 0.0:
		house_timer_count_down(delta)
	if run_away_state:
		run_away_count_down(delta)
	velocity = direction * speed
	move_and_slide()
	

func set_current_intersection(inter: Intersection): #called by intersection signal
	if inter == current_intersection and not run_away_state:
		return
	current_intersection = inter
	
	var snapped = inter.global_position.snapped(Vector2(tile_size, tile_size))
	global_position = snapped
	
	if not pacman:
		return
		
	var dist_to_pac = current_intersection.global_position.distance_to(pacman.global_position)
	var chase_threshold = tile_size * 8

	if run_away_state:
		direction = get_random_direction()
		current_intersection = null
		return

	var target_pos: Vector2
	if dist_to_pac > chase_threshold:
		target_pos = pacman.global_position
	else:
		target_pos = scatter_corner_pos

	direction = get_astar_direction_to_position(target_pos)
		
func get_nearest_intersection(target_pos: Vector2) -> Intersection:
	var intersections = graph.get_children().filter(func(n): return n is Intersection)
	var best: Intersection = null
	var best_dist = INF
	for inter in intersections:
		var d = inter.global_position.distance_to(target_pos)
		if d < best_dist:
			best_dist = d
			best = inter
	return best

func get_astar_direction_to_position(target_pos: Vector2) -> Vector2:
	if not current_intersection:
		return direction
	
	var target_intersection = get_nearest_intersection(target_pos)
	
	#If target doesn't change due to offset being off-limits
	if target_intersection == current_intersection:
		var best_score = INF
		var best_dir = null
		for dir in target_intersection.neighbors.keys():
			if dir == -direction:
				continue
			var neighbor = current_intersection.neighbors[dir]["neighbor"]
			var score = calculate_heuristic(neighbor, target_pos) + current_intersection.neighbors[dir]["cost"]
			if score < best_score:
				best_score = score
				best_dir = dir
		return best_dir

	var intersections = graph.get_children().filter(func(n): return n is Intersection)
	var open_set := [current_intersection]
	var closed_set := []
	var came_from = {}
	var g_score = {}
	var f_score = {}
	for inter in intersections:
		g_score[inter] = INF
		f_score[inter] = INF
	g_score[current_intersection] = 0
	f_score[current_intersection] = calculate_heuristic(current_intersection, target_intersection.global_position)

	while open_set.size() > 0:
		var current = open_set[0]
		for node in open_set:
			if f_score[node] < f_score[current]:
				current = node
		if current == target_intersection:
			break

		open_set.erase(current)
		closed_set.append(current)

		# explore neighbors
		for dir in current.neighbors.keys():
			if current == current_intersection and dir == -direction:
				continue
			var neighbor = current.neighbors[dir]["neighbor"]
			if neighbor in closed_set:
				continue
			var cost = current.neighbors[dir]["cost"]
			var tentative_g = g_score[current] + cost
			if tentative_g < g_score[neighbor]:
				came_from[neighbor] = {"from": current, "dir": dir}
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + calculate_heuristic(neighbor, target_intersection.global_position)
				if neighbor not in open_set:
					open_set.append(neighbor)

	if not came_from.has(target_intersection):
		return direction

	var step = target_intersection
	while came_from[step]["from"] != current_intersection:
		step = came_from[step]["from"]
	#debug.set_debug_path(reconstruct_path(came_from, current_intersection, target_intersection), Color.ORANGE)
	return came_from[step]["dir"]

func calculate_heuristic(neighbor: Intersection, target_pos: Vector2) -> float:
	return neighbor.global_position.distance_to(target_pos)

func run_away():
	if house_timer >= 0.0:
		return
	if(run_away_state):
		run_away_timer = 7.0
		return
	run_away_state = true
	var texture = load("res://Assets/sprites/run_away.png")
	$Sprite2D.texture = texture
	if current_intersection and not global_position.distance_to(current_intersection.position) < tile_size * 0.5:
		direction = -direction
	speed = 35.0
	
func run_away_count_down(delta):
	run_away_timer -= delta
	if run_away_timer <= 0:
		run_away_state = false
		var texture = load("res://Assets/sprites/clyde.png")
		$Sprite2D.texture = texture
		run_away_timer = 7.0
		speed = 70.0

func house_timer_count_down(delta):
	#print(house_timer)
	house_timer -= delta
	if house_timer <= 0:
		self.position = Vector2(152.0, 136.0)
		direction = Vector2.LEFT
		run_away_state = false

func get_random_direction() -> Vector2:
	if not current_intersection:
		return direction
	var directions : Array[Vector2]
	for dir in current_intersection.neighbors.keys():
		# Don’t reverse
		if dir == -direction:
			continue
		directions.append(dir)
	
	return directions.pick_random()

func reconstruct_path(came_from: Dictionary, start: Intersection, goal: Intersection) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var current = goal
	
	while current != start:
		path.insert(0, current.global_position)
		current = came_from[current]["from"]
	
	path.insert(0, start.global_position)
	return path


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
	var texture = load("res://Assets/sprites/clyde.png")
	$Sprite2D.texture = texture
	direction = Vector2.LEFT
	LifeManager.score += 1000
	scoring.score_board.set_text(str(LifeManager.score))
	self.position = Vector2(152, 136)
