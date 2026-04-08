extends Area2D

const SPEED := 400.0

var direction := Vector2.UP
var is_player_bullet := false

func _ready() -> void:
	rotation = direction.angle() + PI / 2

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_hit(area)

func _hit(other) -> void:
	if other == get_parent():
		return
	if other.is_in_group("bullet"):
		other.queue_free()
		queue_free()
		return
	if other.is_in_group("brick"):
		other.damage()
		queue_free()
		return
	if other.is_in_group("steel"):
		queue_free()
		return
	if other.is_in_group("base"):
		other.destroy()
		queue_free()
		return
	if is_player_bullet and other.is_in_group("enemy"):
		other.take_damage()
		queue_free()
		return
	if not is_player_bullet and other.is_in_group("player"):
		other.take_damage()
		queue_free()
		return
