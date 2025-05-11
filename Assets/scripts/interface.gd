extends CanvasLayer

class_name interface 

@onready var game_clear = $MarginContainer/CenterContainer
@onready var game_start = $MarginContainer/CenterContainer2
var timer = 1.5
var status : bool = true


func _ready():
	game_clear.hide()
	game_start.show()
	get_parent().get_tree().paused = true
	
func _physics_process(delta: float):
	timer -= delta
	if timer <= 0.0 and status:
		status = false
		game_start.hide()
		get_parent().get_tree().paused = false
	

func game_won(score):
	var victory_label = $MarginContainer/CenterContainer/Panel/Label
	game_clear.show()
	LifeManager.lives = 3
	LifeManager.score = 0
	LifeManager.pellets_amount = 0
	LifeManager.pellets_eaten.clear()
	victory_label.set_text("Você venceu!" + "\nPontuação: " + str(score))
	get_parent().get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_parent().get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
