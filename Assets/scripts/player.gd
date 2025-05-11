extends CharacterBody2D

class_name player

var movement_direction = Vector2.ZERO
var next_movement_direction = Vector2.ZERO
var next_rotation_degrees = 0
var shape_query = PhysicsShapeQueryParameters2D.new()
var lifes = 3

@export var grid_size = 16
@export var speed = 90
@onready var collision_shape_2d = $CollisionShape2D
@onready var map = $"../level"

func _ready(): 
	print(self.position)
	shape_query.shape = collision_shape_2d.shape
	shape_query.collision_mask = 2

func _physics_process(delta):
	get_input()
	
	if movement_direction == Vector2.ZERO:
		movement_direction = next_movement_direction
		rotation_degrees = next_rotation_degrees
	if can_move(next_movement_direction, delta):
		movement_direction = next_movement_direction
		rotation_degrees = next_rotation_degrees
	
	velocity = movement_direction * speed
	move_and_slide()
	
func get_input():
	if Input.is_action_pressed("ui_left"):
		next_movement_direction = Vector2.LEFT
		next_rotation_degrees = 0
	elif Input.is_action_pressed("ui_right"):
		next_movement_direction = Vector2.RIGHT
		next_rotation_degrees = 180
	elif Input.is_action_pressed("ui_down"):
		next_movement_direction = Vector2.DOWN
		next_rotation_degrees = 270
	elif Input.is_action_pressed("ui_up"):
		next_movement_direction = Vector2.UP
		next_rotation_degrees = 90

func can_move(dir: Vector2, delta: float) -> bool:
	shape_query.transform = global_transform.translated(dir * speed * delta * 2)
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0
	
func die():
	get_parent().get_tree().paused = true
	await get_tree().create_timer(2).timeout
	LifeManager.lives -= 1
	if LifeManager.lives <= 0:
		LifeManager.lives = 3
		LifeManager.score = 0
		LifeManager.pellets_amount = 0
		LifeManager.pellets_eaten.clear()
		get_parent().get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
		return
	get_parent().get_tree().reload_current_scene()
	print("ok")
