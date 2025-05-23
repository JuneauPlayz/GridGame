extends Node2D

@onready var grid: GridContainer = $Grid
const PLATFORM = preload("res://battle/platform/platform.tscn")
@onready var grid_helper: Node = $Grid/GridHelper
const CAST_TIMER = preload("res://cast_timer.tscn")
@onready var player: Node2D = $Player
@onready var cast_timers: VBoxContainer = $CastTimers
@onready var health_text: Label = $Camera2D/CanvasLayer/HealthText
@onready var enemy: Node2D = $Enemy
	
var grid_arr = []

var game

var rows = 6
var cols = 6

var platform_size = 75
var player_size = 25

func _ready():
	game = get_tree().get_first_node_in_group("game")
	setup_grid(rows,cols,platform_size)
	await get_tree().process_frame
	player.grid = grid_arr
	player.platform_size = platform_size
	player.player_size = player_size
	move_player(0,0)
	player.current_platform = grid_arr[0][0]
	set_enemy()
	start_fight2()
	
func start_fight():
	var current_attack = []
	start_cast_timer("Attack 1", 2.0)
	await get_tree().create_timer(2).timeout
	for platform in grid_helper.get_col(0):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_col(4):
		platform.transition("PlatformOrange",3)
	
	start_cast_timer("Attack 2", 2.0)
	await get_tree().create_timer(2).timeout
	for platform in grid_helper.get_col(2):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_col(3):
		platform.transition("PlatformOrange",3)
	
	
	await get_tree().create_timer(3.5).timeout
	start_cast_timer("Attack 3", 2.0)
	await get_tree().create_timer(2.0).timeout
	for platform in grid_helper.get_diagonal(2):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_diagonal(1):
		platform.transition("PlatformOrange",3)
		
	await get_tree().create_timer(3.5).timeout
	start_cast_timer("Attack 4", 3.0)
	await get_tree().create_timer(3.0).timeout
	for platform in grid_helper.get_diagonal(1):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_row(1):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_row(3):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_row(5):
		platform.transition("PlatformOrange",3)
		
	await get_tree().create_timer(3.5).timeout
	start_cast_timer("Attack 5", 3.0)
	await get_tree().create_timer(3.0).timeout
	for platform in grid_helper.get_row(0):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_row(2):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_row(4):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_col(0):
		platform.transition("PlatformOrange",3)
	for platform in grid_helper.get_col(4):
		platform.transition("PlatformOrange",3)
		
func start_fight2():
	for platform in grid_helper.get_mid_block():
		platform.transition("PlatformBlack", -1)
		platform.visible = false

	#await get_tree().create_timer(0.5).timeout
	#await attack("lefty", 2.0)
	#await get_tree().create_timer(0.5).timeout
	#await attack("righty", 2.0)
	#await get_tree().create_timer(0.5).timeout
	#await attack("uppercut", 2.0)
	#await get_tree().create_timer(0.5).timeout
	#await attack("low_blow", 2.0)
#
	#await get_tree().create_timer(2.0).timeout
	#await attack("lefty", 2.0)
	#await get_tree().create_timer(1.75).timeout
	#await attack("righty", 2.0)
	#await get_tree().create_timer(1.75).timeout
	#await attack("lefty", 2.0)
	#await get_tree().create_timer(3).timeout
	#start_cast_timer("Fakeout", 2.0)
	#await get_tree().create_timer(2.5).timeout
	#await attack("lefty", 2.0, true)
	#await get_tree().create_timer(3).timeout
	#start_cast_timer("Fakeout", 2.0)
	#await get_tree().create_timer(2.5).timeout
	#await attack("uppercut", 2.0, true)
#
	#await get_tree().create_timer(2.0).timeout
	#await attack("inner_ring", 2.0)
	#await get_tree().create_timer(3.0).timeout
	#await attack("outer_ring", 2.0)
#
	#await get_tree().create_timer(3.0).timeout
	#await attack("outer_ring", 2.0)
	#await attack("lefty", 2.0)
#
	#await get_tree().create_timer(3.0).timeout
	#await attack("inner_ring", 2.0)
	#await attack("lefty", 2.0)
	#await attack("low_blow", 2.0)
#
	#await get_tree().create_timer(3.0).timeout
	#await attack("inner_ring", 2.0)
	#await attack("lefty", 2.0)
#
	#await get_tree().create_timer(2.0).timeout
	#await attack("outer_ring", 2.0)
	#await attack("righty", 2.0)

	await get_tree().create_timer(3.0).timeout
	start_cast_timer("Turning Point", 2.0)
	await get_tree().create_timer(2.0).timeout
	rotate_enemy(90)
	await get_tree().create_timer(1.0).timeout
	await attack("lefty", 2.0)
	await get_tree().create_timer(1.0).timeout
	await attack("uppercut", 2.0)

func attack(name: String, cast_time: float, fakeout := false):
	var mapped_attack = get_mapped_attack(name, fakeout)
	start_cast_timer(name.capitalize(), cast_time)
	await get_tree().create_timer(cast_time).timeout

	var targets = []
	match mapped_attack:
		"left":
			targets = grid_helper.get_half("left")
		"right":
			targets = grid_helper.get_half("right")
		"top":
			targets = grid_helper.get_half("top")
		"bottom":
			targets = grid_helper.get_half("bottom")
		"outer_ring":
			targets = grid_helper.get_outer_ring()
		"inner_ring":
			targets = grid_helper.get_middle_ring()

	for platform in targets:
		platform.transition("PlatformOrange", 1)

func get_mapped_attack(name: String, fakeout: bool) -> String:
	var angle = int(round(rad_to_deg(enemy.rotation))) % 360
	if angle % 90 != 0:
		angle = 0  # Fallback for non-orthogonal rotations

	var map = {
		"lefty": ["left", "right"],
		"righty": ["right", "left"],
		"uppercut": ["top", "bottom"],
		"low_blow": ["bottom", "top"]
	}

	var direction = map.get(name, name)
	if direction is String:
		return direction  # for "outer_ring", etc.

	var primary = direction[0]
	var fake = direction[1]

	var rotation_to_direction = {
		0: {"left": "left", "right": "right", "top": "top", "bottom": "bottom"},
		90: {"left": "top", "right": "bottom", "top": "right", "bottom": "left"},
		180: {"left": "right", "right": "left", "top": "bottom", "bottom": "top"},
		270: {"left": "bottom", "right": "top", "top": "left", "bottom": "right"}
	}

	var rot_map = rotation_to_direction.get(angle, rotation_to_direction[0])
	if fakeout:
		return rot_map[fake]
	else:
		return rot_map[primary]


func rotate_enemy(deg):
	enemy.rotation = deg_to_rad(deg)

	
func start_cast_timer(name, length):
	var new_cast_timer = CAST_TIMER.instantiate()
	new_cast_timer.call_deferred("start", name, length)
	cast_timers.add_child(new_cast_timer)
	
func setup_grid(rows, cols, size):
	grid.columns = cols
	grid.set("theme_override_constants/h_separation", size + 5)
	grid.set("theme_override_constants/v_separation", size + 5)
	grid.queue_sort()
	
	grid_arr.clear()
	
	for i in range(rows):
		var row_arr = []
		for j in range(cols):
			var new_platform = PLATFORM.instantiate()
			new_platform.call_deferred("set_size", size, size)
			var padded = MarginContainer.new()
			padded.add_child(new_platform)
			padded.set("theme_override_constants/margin_top", size/4)
			padded.set("theme_override_constants/margin_bottom", size/4)
			padded.set("theme_override_constants/margin_left", size/4)
			padded.set("theme_override_constants/margin_right", size/4)

			grid.add_child(padded)
			row_arr.append(new_platform)
		grid_arr.append(row_arr)
	grid_helper.grid_arr = grid_arr


func move_player(x, y):
	player.global_position = grid_arr[y][x].get_pos() + Vector2(platform_size/2, platform_size/2) - Vector2(player_size/2, player_size/2)
	player.current_platform = grid_arr[y][x]
	
func _on_player_health_changed() -> void:
	health_text.text = "Health: " + str(player.health)

func set_enemy():
	var platform_center_offset = Vector2(platform_size / 2, platform_size / 2)
	var a = grid_arr[2][2].get_pos() + platform_center_offset
	var b = grid_arr[2][3].get_pos() + platform_center_offset
	var c = grid_arr[3][2].get_pos() + platform_center_offset
	var d = grid_arr[3][3].get_pos() + platform_center_offset
	
	enemy.global_position =  (a + b + c + d) / 4
