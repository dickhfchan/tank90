extends CharacterBody2D

const SPEED := 150.0
const BULLET_SCENE = preload("res://scenes/Bullet.tscn")
const FIRE_COOLDOWN := 0.2
const MAX_BULLETS := 3
const TILE := 32.0
const SNAP_THRESHOLD := 6.0  # pixels — only snap when this close to grid line

var facing := Vector2.UP
var fire_timer := 0.0
var bullet_on_screen := 0
var invincible := false
var invincible_timer := 0.0
var alive := true

@onready var sprite: ColorRect = $Sprite
@onready var gun_tip: Marker2D = $GunTip

func _ready() -> void:
	add_to_group("player")
	set_invincible(2.0)

func _physics_process(delta: float) -> void:
	if not alive:
		return

	if invincible:
		invincible_timer -= delta
		sprite.modulate.a = 1.0 if fmod(invincible_timer * 10, 2.0) > 1.0 else 0.3
		if invincible_timer <= 0:
			invincible = false
			sprite.modulate.a = 1.0

	fire_timer = max(0, fire_timer - delta)

	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		dir = Vector2.RIGHT

	if dir != Vector2.ZERO:
		facing = dir
		# Soft-snap: nudge the perpendicular axis toward the nearest grid centre
		# only when close enough, so turning feels responsive without jerking.
		if dir.x != 0:
			var snapped_y = round(position.y / TILE) * TILE
			var err = snapped_y - position.y
			if abs(err) < SNAP_THRESHOLD:
				position.y = snapped_y
			else:
				position.y += err * 0.3  # drift gently toward alignment
		else:
			var snapped_x = round(position.x / TILE) * TILE
			var err = snapped_x - position.x
			if abs(err) < SNAP_THRESHOLD:
				position.x = snapped_x
			else:
				position.x += err * 0.3
		velocity = dir * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	rotation = facing.angle() + PI / 2
	gun_tip.position = Vector2(0, -16)

	if Input.is_action_just_pressed("shoot") or (Input.is_action_pressed("shoot") and fire_timer == 0):
		_shoot()

func _shoot() -> void:
	if fire_timer > 0 or bullet_on_screen >= MAX_BULLETS:
		return
	fire_timer = FIRE_COOLDOWN
	bullet_on_screen += 1
	var b = BULLET_SCENE.instantiate()
	b.direction = facing
	b.is_player_bullet = true
	b.position = gun_tip.global_position
	b.tree_exited.connect(_on_bullet_gone)
	get_tree().root.get_node("Main").add_child(b)

func _on_bullet_gone() -> void:
	bullet_on_screen -= 1

func take_damage() -> void:
	if invincible:
		return
	alive = false
	visible = false
	var gm = get_node("/root/GameManager")
	gm.lose_life()
	if gm.lives > 0:
		await get_tree().create_timer(2.0).timeout
		respawn()

func respawn() -> void:
	position = Vector2(320, 592)
	alive = true
	visible = true
	set_invincible(2.0)

func set_invincible(duration: float) -> void:
	invincible = true
	invincible_timer = duration
