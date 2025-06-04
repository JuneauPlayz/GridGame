extends Node2D

var grid
var platform_size
var player_size

@onready var invuln_timer: Timer = $InvulnTimer
@onready var sprite: ColorRect = $ColorRect
var tween
@onready var effect_label: Label = $Effect
@onready var ability_1_vis: Node2D = $Ability1
@onready var ability_2_vis: Node2D = $Ability2

var current_platform
var x = 0
var y = 0
var is_moving = false
var is_invuln = false
var health = 3

var move_distance = 1
var dash_distance = 3

signal health_changed
signal moved
signal dead

var dash = false
var last_move = "none"
var can_move = true
var silenced = false

func _ready():
	player_size = sprite.size.x

func _process(delta):
	if Input.is_action_just_pressed("up"):
		_attempt_move(Vector2i(0, -1))
	if Input.is_action_just_pressed("down"):
		_attempt_move(Vector2i(0, 1))
	if Input.is_action_just_pressed("left"):
		_attempt_move(Vector2i(-1, 0))
	if Input.is_action_just_pressed("right"):
		_attempt_move(Vector2i(1, 0))
	if current_platform.get_state() is PlatformRed and is_invuln == false:
		take_damage(1)


func _attempt_move(direction: Vector2i):
	if not can_move:
		return
	var is_dashing = dash
	var max_steps
	if is_dashing:
		max_steps = dash_distance
		dash = false
		AudioPlayer.play_FX("dash")
	else:
		max_steps = move_distance
	
	
	var new_x = x
	var new_y = y

	var last_valid_x = x
	var last_valid_y = y

	for step in range(1, max_steps + 1):
		var target_x = x + direction.x * step
		var target_y = y + direction.y * step

		if target_y < 0 or target_y >= grid.size() or target_x < 0 or target_x >= grid[0].size():
			break

		var target_platform = grid[target_y][target_x]

		if is_dashing:
			if target_platform.get_state() is not PlatformBlack and target_platform.get_state() is not PlatformBlue:
				last_valid_x = target_x
				last_valid_y = target_y
			# continue regardless of wall to see if farther tiles are reachable
		else:
			if target_platform.get_state() is PlatformBlack or target_platform.get_state() is PlatformBlue:
				break
			last_valid_x = target_x
			last_valid_y = target_y


	if last_valid_x != x or last_valid_y != y:
		x = last_valid_x
		y = last_valid_y
		move_player(x, y)



func move_player(x, y):
	var target_pos = grid[y][x].get_pos() + Vector2(platform_size / 2, platform_size / 2) - Vector2(player_size / 2, player_size / 2)
	tween = create_tween()
	is_moving = true
	moved.emit()
	tween.tween_property(self, "global_position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Wait for halfway
	current_platform = grid[y][x]
	self.x = x
	self.y = y
	await tween.finished
	is_moving = false



func take_damage(amt):
	lose_health(amt)
	invuln_timer.start()
	is_invuln = true
	
func lose_health(amt):
	health -= amt
	health_changed.emit()
	if health <= 0:
		dead.emit()

func activate_dash():
	dash = true

func _on_invuln_timer_timeout() -> void:
	is_invuln = false

func ability_1():
	ability_1_vis.visible = true
	await get_tree().create_timer(0.1).timeout
	ability_1_vis.visible = false

func ability_2():
	ability_2_vis.visible = true
	await get_tree().create_timer(0.1).timeout
	ability_2_vis.visible = false

func ability_3():
	effect("dash!", 0.2)

func ability_4():
	is_invuln = true
	invuln_timer.start()
	effect("invuln!", 0.5)
	
func effect(text, length):
	effect_label.text = text
	effect_label.visible = true
	await get_tree().create_timer(length).timeout
	effect_label.visible = false

func knock_back(side: String, platforms: int) -> void:
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
		return  # Invalid direction

	var direction = dir_map[side]

	var new_x = x
	var new_y = y

	for step in range(1, platforms + 1):
		var test_x = x + direction.x * step
		var test_y = y + direction.y * step

		# Bounds check
		if test_y < 0 or test_y >= grid.size():
			break
		if test_x < 0 or test_x >= grid[0].size():
			break

		var tile = grid[test_y][test_x]
		var state = tile.get_state()

		# Stop if last platform is blocked
		if step == platforms and (state is PlatformBlack or state is PlatformBlue):
			break

		# Otherwise allow passthrough
		new_x = test_x
		new_y = test_y

	# Move if valid
	if new_x != x or new_y != y:
		x = new_x
		y = new_y
		move_player(new_x, new_y)
