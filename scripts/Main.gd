extends Node2D

@onready var gm = get_node("/root/GameManager")
@onready var walls: Node2D = $Walls
@onready var game_over_label: Label = $HUD/GameOverLabel
@onready var stage_clear_label: Label = $HUD/StageClearLabel

func _ready() -> void:
	MapBuilder.build(walls, gm.stage)

	gm.game_over.connect(_on_game_over)
	gm.stage_clear.connect(_on_stage_clear)
	gm.score_changed.connect(_on_score_changed)
	gm.lives_changed.connect(_on_lives_changed)
	_update_hud()

func _on_game_over() -> void:
	game_over_label.visible = true
	await get_tree().create_timer(3.0).timeout
	gm.score = 0
	gm.lives = 3
	gm.stage = 1
	get_tree().reload_current_scene()

func _on_stage_clear() -> void:
	stage_clear_label.visible = true
	await get_tree().create_timer(3.0).timeout
	gm.stage += 1
	get_tree().reload_current_scene()

func _on_score_changed(s: int) -> void:
	$HUD/ScoreLabel.text = "SCORE: %d" % s

func _on_lives_changed(l: int) -> void:
	$HUD/LivesLabel.text = "LIVES: %d" % l

func _update_hud() -> void:
	$HUD/ScoreLabel.text = "SCORE: %d" % gm.score
	$HUD/LivesLabel.text = "LIVES: %d" % gm.lives
	$HUD/StageLabel.text = "STAGE: %d" % gm.stage
