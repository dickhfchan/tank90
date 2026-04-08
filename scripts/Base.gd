extends StaticBody2D

@onready var sprite: ColorRect = $Sprite

func _ready() -> void:
	add_to_group("base")

func destroy() -> void:
	sprite.color = Color(0.3, 0.3, 0.3)
	# Disable collision
	$CollisionShape2D.disabled = true
	remove_from_group("base")
	get_node("/root/GameManager").game_over.emit()
