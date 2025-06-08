extends Node2D


var grid
var platform_size
var cannonball_size

var current_platform
var x = 0
var y = 0
var is_moving = false

signal weakpoint_hit
signal ship_hit

var fight
@onready var sprite: ColorRect = $ColorRect
var tween

func _ready():
	cannonball_size = sprite.size.x

func move_to(x, y):
	var target_pos = grid[y][x].get_pos() + Vector2(platform_size / 2, platform_size / 2) - Vector2(cannonball_size / 2, cannonball_size / 2)
	tween = create_tween()
	is_moving = true
	tween.tween_property(self, "global_position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	current_platform = grid[y][x]
	self.x = x
	self.y = y
	await get_tree().create_timer(0.135).timeout
	if current_platform.grid_y == 0:
		ship_hit.emit()
		if current_platform.ball_weakpoint == true:
			weakpoint_hit.emit()
		self.queue_free()
	await tween.finished
	is_moving = false

	

func knock_back(side: String, distance: int) -> void:
	var dir_map = {
		"top": Vector2i(0, -1),
		"top_right": Vector2i(1, -1),
		"right": Vector2i(1, 0),
		"bottom_right": Vector2i(1, 1),
		"bottom": Vector2i(0, 1),
		"bottom_left": Vector2i(-1, 1),
		"left": Vector2i(-1, 0),
		"top_left": Vector2i(-1, -1)
	}

	if not dir_map.has(side):
		return

	var direction = dir_map[side]
	var target_x = self.x
	var target_y = self.y

	for step in range(1, distance + 1):
		var test_x = self.x + direction.x * step
		var test_y = self.y + direction.y * step

		# Bounds check
		if test_y < 0 or test_y >= grid.size():
			break
		if test_x < 0 or test_x >= grid[0].size():
			break

		var tile = grid[test_y][test_x]
		var state = tile.get_state()
		
		if tile == fight.player.current_platform:
			break
		# If final tile is blocked, stop BEFORE moving onto it
		if step == distance and (((state is PlatformBlack or state is PlatformBlue) and tile.is_enemy == false) or tile == fight.player.current_platform):
			break

		# Otherwise, we can pass through or land on it
		if state is not PlatformBlack or tile.is_enemy == true:
			target_x = test_x
			target_y = test_y

	if target_x != self.x or target_y != self.y:
		await move_to(target_x, target_y)
