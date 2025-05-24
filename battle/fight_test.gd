extends Node2D

@onready var grid: GridContainer = $Grid
const PLATFORM = preload("res://battle/platform/platform.tscn")
@onready var grid_helper: Node = $Grid/GridHelper
const CAST_TIMER = preload("res://cast_timer.tscn")
@onready var player: Node2D = $Player
@onready var cast_timers: VBoxContainer = $CastTimers
@onready var health_text: Label = $Camera2D/CanvasLayer/HealthText
@onready var enemy: Node2D = $Enemy
@onready var abilities: Control = $Abilities
@onready var enemy_hp_bar: ProgressBar = $EnemyHPBar
@onready var enemy_hp_label: Label = $EnemyHPLabel

var grid_arr = []

var game

var rows = 6
var cols = 6

var platform_size = 75
var player_size = 25

var current_player_side = ""

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
	enemy.new_weakpoint()
	
	for platform in grid_helper.get_mid_block():
		platform.transition("PlatformBlack", -1)
		platform.visible = false
		platform.set_enemy(true)

	#await get_tree().create_timer(0.5).timeout
	#await attack("lefty", 2.0)
	#await get_tree().create_timer(0.5).timeout
	#await attack("righty", 2.0)
	#await get_tree().create_timer(0.5).timeout
	#await attack("uppercut", 2.0)
	#await get_tree().create_timer(0.5).timeout
	#await attack("low_blow", 2.0)

	#await get_tree().create_timer(2.0).timeout
	#attack("lefty", 2.0)
	#await get_tree().create_timer(1.75).timeout
	#attack("righty", 2.0)
	#await get_tree().create_timer(1.75).timeout
	#attack("lefty", 2.0)
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
	#attack("outer_ring", 2.0)
	#attack("lefty", 2.0)
#
	#await get_tree().create_timer(4.0).timeout
	#attack("inner_ring", 2.0)
	#attack("lefty", 2.0)
	#attack("low_blow", 2.0)

	await get_tree().create_timer(4.0).timeout
	attack("inner_ring", 2.0)
	attack("lefty", 2.0)

	await get_tree().create_timer(4.0).timeout
	attack("outer_ring", 2.0)
	attack("righty", 2.0)
	
	await get_tree().create_timer(1.75).timeout
	await attack("lefty", 2.0)
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
	set_player_side()

	
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
	AudioPlayer.play_FX("hit")
	health_text.text = "Health: " + str(player.health)

func set_enemy():
	var platform_center_offset = Vector2(platform_size / 2, platform_size / 2)
	var a = grid_arr[2][2].get_pos() + platform_center_offset
	var b = grid_arr[2][3].get_pos() + platform_center_offset
	var c = grid_arr[3][2].get_pos() + platform_center_offset
	var d = grid_arr[3][3].get_pos() + platform_center_offset
	
	enemy.global_position =  (a + b + c + d) / 4
	
	enemy_hp_bar.max_value = enemy.health
	enemy_hp_bar.value = enemy.health
	enemy_hp_label.text = "Enemy HP: " + str(enemy.health) + "/" + str(enemy.max_health)
	
func _on_abilities_ability_1_used() -> void:
	var enemy_hit = false
	for platform in grid_helper.get_sides(player.player_x, player.player_y):
		if platform.is_enemy:
			enemy_hit = true
	if enemy_hit:
		enemy.take_damage(abilities.ability_1_dmg)
	player.ability_1()
	AudioPlayer.play_FX("click")

func _on_abilities_ability_2_used() -> void:
	var enemy_hit = false
	for platform in grid_helper.get_cross(player.player_x, player.player_y):
		if platform.is_enemy:
			enemy_hit = true
	if enemy_hit:
		enemy.take_damage(abilities.ability_2_dmg)
	player.ability_2()
	AudioPlayer.play_FX("click")
	
func _on_abilities_ability_3_used() -> void:
	player.activate_dash()
	player.ability_3()
	AudioPlayer.play_FX("click")


func _on_abilities_ability_4_used() -> void:
	player.ability_4()
	AudioPlayer.play_FX("click")


func _on_enemy_damage_taken() -> void:
	enemy_hp_bar.value = enemy.health
	enemy_hp_label.text = "Enemy HP: " + str(enemy.health) + "/" + str(enemy.max_health)
	if enemy.weakpoint_side == current_player_side:
		enemy.new_weakpoint()
		enemy.take_damage(enemy.weakpoint_damage)
		AudioPlayer.play_FX("fiora")

func _on_enemy_dead() -> void:
	pass # Replace with function body.


func _on_player_moved() -> void:
	set_player_side()

func set_player_side():
	var x = player.player_x
	var y = player.player_y
	# Step 1: Determine raw local side in the grid
	var local_side := "none"
	if x in [0, 1] and y in [2, 3]:
		local_side = "left"
	elif x in [4, 5] and y in [2, 3]:
		local_side = "right"
	elif y in [0, 1] and x in [2, 3]:
		local_side = "top"
	elif y in [4, 5] and x in [2, 3]:
		local_side = "bottom"

	# Step 2: Adjust based on enemy rotation (clockwise)
	var angle = int(round(rad_to_deg(enemy.rotation))) % 360
	var rotation_map = {
		0:    {"top": "front", "bottom": "back",  "left": "left",  "right": "right"},
		90:   {"top": "left",  "bottom": "right", "left": "back", "right": "front"},
		180:  {"top": "back",  "bottom": "front", "left": "right", "right": "left"},
		270:  {"top": "right", "bottom": "left",  "left": "front",  "right": "back"},
	}


	var mapped = rotation_map.get(angle, rotation_map[0])
	current_player_side = mapped.get(local_side, "none")
	print(current_player_side)
