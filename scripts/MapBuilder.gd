extends Node

# Builds the stage map programmatically.
# Call build(walls_node) from Main._ready()

const BRICK = preload("res://scenes/BrickWall.tscn")
const STEEL = preload("res://scenes/SteelWall.tscn")
const BASE  = preload("res://scenes/Base.tscn")

const T := 32  # tile size

# Stage 1 layout (classic Battle City)
# Grid: 20x20 tiles, 0-indexed
# B = brick, S = steel, . = empty
# Each cell = one 32x32 tile
# The playfield is offset 0,0 (top-left of first tile center at 16,16)

static func stage1_map() -> Array:
	# Returns array of [type, col, row] where type: 0=brick, 1=steel
	var cells: Array = []

	# Border walls (steel)
	for c in range(20):
		cells.append([1, c, 0])
		cells.append([1, c, 19])
	for r in range(1, 19):
		cells.append([1, 0, r])
		cells.append([1, 19, r])

	# Classic internal brick layout (stage 1 approximation)
	# Cluster bricks in standard Battle City patterns
	var brick_cols = [2, 3, 6, 7, 10, 11, 14, 15, 16, 17]
	for r in [2, 3, 4, 8, 9, 10, 14, 15, 16]:
		for c in brick_cols:
			if c < 19 and r < 19:
				cells.append([0, c, r])

	# Vertical brick strips
	for r in [5, 6, 7, 11, 12, 13]:
		cells.append([0, 2, r])
		cells.append([0, 7, r])
		cells.append([0, 12, r])
		cells.append([0, 17, r])

	# Steel obstacles mid-field
	for c in [4, 5, 9, 10, 13, 14]:
		cells.append([1, c, 6])
		cells.append([1, c, 12])

	# Base protection bricks (around center-bottom)
	# Base is at col 9-10, row 17-18 (center bottom area)
	var base_bricks = [
		[0, 8, 15], [0, 9, 15], [0, 10, 15], [0, 11, 15],
		[0, 8, 16], [0, 11, 16],
		[0, 8, 17], [0, 11, 17],
	]
	cells.append_array(base_bricks)

	return cells

static func build(walls_node: Node2D, stage: int = 1) -> StaticBody2D:
	var cells = stage1_map()

	# Remove duplicates (a cell shouldn't have two tiles)
	var seen: Dictionary = {}
	for cell in cells:
		var key = "%d,%d" % [cell[1], cell[2]]
		if not seen.has(key):
			seen[key] = cell

	for key in seen:
		var cell = seen[key]
		var type = cell[0]
		var col  = cell[1]
		var row  = cell[2]
		var pos  = Vector2(col * T + T/2, row * T + T/2)

		var node
		if type == 0:
			node = BRICK.instantiate()
		else:
			node = STEEL.instantiate()
		node.position = pos
		walls_node.add_child(node)

	# Place base at center-bottom
	var base = BASE.instantiate()
	base.position = Vector2(9 * T + T/2, 18 * T + T/2)  # col 9, row 18
	walls_node.add_child(base)
	return base
