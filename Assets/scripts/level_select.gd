extends Control

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game2.tscn")


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game3.tscn")
