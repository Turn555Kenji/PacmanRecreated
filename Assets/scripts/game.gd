extends Node2D

@onready var pellet_container := $pellets

func _ready():
	_restore_pellets()

func _restore_pellets():
	if LifeManager.lives > 0:
		for pellet in pellet_container.get_children():
			if pellet.global_position in LifeManager.pellets_eaten:
				pellet.queue_free()
