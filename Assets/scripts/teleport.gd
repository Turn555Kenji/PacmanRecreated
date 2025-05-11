extends Node2D


@onready var left_area_2d = $left
@onready var right_area_2d = $right

var left_tp = true
var right_tp = true

func _on_left_body_entered(body: Node2D) -> void:
	if body.velocity.x < 0:
		body.position.x = right_area_2d.global_position.x
		right_tp = false
	

func _on_left_body_exited(body: Node2D) -> void:
	left_tp = true


func _on_right_body_entered(body: Node2D) -> void:
	if body.velocity.x > 0:
		body.position.x = left_area_2d.global_position.x
		left_tp = false


func _on_right_body_exited(body: Node2D) -> void:
	right_tp = true
