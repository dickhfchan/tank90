extends StaticBody2D

var hits := 2

@onready var sprite: ColorRect = $Sprite

func _ready() -> void:
	add_to_group("brick")

func damage() -> void:
	hits -= 1
	if hits <= 0:
		queue_free()
	else:
		# Show cracked state (darker)
		sprite.color = Color(0.5, 0.25, 0.0)
