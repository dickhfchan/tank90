extends Node

signal game_over
signal stage_clear
signal lives_changed(lives: int)
signal score_changed(score: int)

const TILE_SIZE := 32
const GRID_W := 20
const GRID_H := 20

var score := 0
var lives := 3
var stage := 1
var enemies_killed := 0
var enemies_spawned := 0
var max_enemies_on_field := 4
var total_enemies_per_stage := 20

func _ready() -> void:
	pass

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

func enemy_killed() -> void:
	enemies_killed += 1
	if enemies_killed >= total_enemies_per_stage:
		stage_clear.emit()

func start_stage(s: int) -> void:
	stage = s
	enemies_killed = 0
	enemies_spawned = 0
