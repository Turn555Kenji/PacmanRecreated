extends Sprite2D

@onready var inky: CharacterBody2D = $"../inky"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position = Vector2(30, 327)
