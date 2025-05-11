extends Area2D


class_name Pellet
signal pellet_eaten(should_allow_eating_ghosts : bool)

@export var should_allow_eating_ghosts = false

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		LifeManager.pellets_eaten.append(global_position)
		pellet_eaten.emit(should_allow_eating_ghosts)
		queue_free()
