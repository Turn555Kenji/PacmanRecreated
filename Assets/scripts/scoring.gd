extends Node

var total_pellets

@onready var game_won_screen: interface = $"../interface"
@onready var score_board: Label = $"../interface/Label"

@export var ghosts : Array[CharacterBody2D]

func _ready() -> void:
	score_board.set_text("Vidas: " + str(LifeManager.lives) + " Pontuação: " + str(LifeManager.score))
	var pellets = self.get_children() as Array[Pellet] #Class name defined in pellet.gd
	total_pellets = pellets.size()
	for pellet in pellets:
		pellet.pellet_eaten.connect(on_pellet_eaten)

func on_pellet_eaten(should_allow_eating_ghosts : bool):
	LifeManager.pellets_amount += 1
	LifeManager.score += 100
	if should_allow_eating_ghosts:
		LifeManager.score += 400
		for ghost in ghosts:
			ghost.run_away()
	score_board.set_text("Vidas: " + str(LifeManager.lives) + " Pontuação: " + str(LifeManager.score))
	
	print(LifeManager.pellets_amount, " ", total_pellets)
	if LifeManager.pellets_amount == total_pellets:
		game_won_screen.game_won(LifeManager.score)
