extends CharacterBody2D

const SPEED := 80.0
const BULLET_SCENE = preload("res://scenes/Bullet.tscn")

var facing := Vector2.DOWN
var move_timer := 0.0
var move_duration := 1.5
var fire_timer := 0.0
var fire_interval := 2.0
var alive := true
var hp := 1
var points := 100

var DIRECTIONS := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

@onready var sprite: ColorRect = $Sprite

func _ready() -> void:
	add_to_group("enemy")
	move_duration = randf_range(0.8, 2.0)
	fire_interval = randf_range(1.5, 3.0)
	_pick_direction()

func _physics_process(delta: float) -> void:
	if not alive:
		return

	move_timer -= delta
	fire_timer -= delta

	if move_timer <= 0:
		move_timer = move_duration
		_pick_direction()

	rotation = facing.angle() + PI / 2
	velocity = facing * SPEED
	move_and_slide()

	# If stuck, pick new direction
	if get_slide_collision_count() > 0:
		move_timer = 0

	if fire_timer <= 0:
		fire_timer = fire_interval
		_shoot()

func _pick_direction() -> void:
	var dirs = DIRECTIONS.duplicate()
	dirs.shuffle()
	facing = dirs[0]

func _shoot() -> void:
	var b = BULLET_SCENE.instantiate()
	b.direction = facing
	b.is_player_bullet = false
	b.position = global_position + facing * 16
	get_tree().root.get_node("Main").add_child(b)

func take_damage() -> void:
	hp -= 1
	if hp <= 0:
		_die()

func _die() -> void:
	alive = false
	var gm = get_node("/root/GameManager")
	gm.add_score(points)
	gm.enemy_killed()
	queue_free()
