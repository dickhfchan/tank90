extends Node2D

const ENEMY_SCENE = preload("res://scenes/EnemyTank.tscn")
const SPAWN_INTERVAL := 3.0

var spawn_points: Array[Vector2] = [
	Vector2(48, 48),
	Vector2(320, 48),
	Vector2(592, 48),
]
var spawn_timer := 1.0  # first spawn quickly
var spawn_index := 0

@onready var gm = get_node("/root/GameManager")

func _ready() -> void:
	gm.start_stage(gm.stage)

func _process(delta: float) -> void:
	if gm.enemies_spawned >= gm.total_enemies_per_stage:
		return

	var enemies_on_field: int = get_tree().get_nodes_in_group("enemy").size()
	if enemies_on_field >= gm.max_enemies_on_field:
		return

	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = SPAWN_INTERVAL
		_spawn_enemy()

func _spawn_enemy() -> void:
	var pos = spawn_points[spawn_index % spawn_points.size()]
	spawn_index += 1

	# Don't spawn on top of player
	var player = get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(pos) < 64:
		pos = spawn_points[(spawn_index) % spawn_points.size()]

	var e = ENEMY_SCENE.instantiate()
	e.position = pos
	get_parent().add_child(e)
	gm.enemies_spawned += 1
