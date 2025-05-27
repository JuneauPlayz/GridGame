extends Node2D

@onready var grid: GridContainer = $Grid
const PLATFORM = preload("res://battle/platform/platform.tscn")
@onready var grid_helper: Node = $Grid/GridHelper
@onready var player: Node2D = $Player
@onready var health_text: Label = $Camera2D/CanvasLayer/HealthText
@onready var enemy: Node2D = $Enemy
@onready var abilities: Control = $Abilities
@onready var enemy_hp_bar: ProgressBar = $EnemyHPBar
@onready var enemy_hp_label: Label = $EnemyHPLabel
@onready var result_screen: Node2D = $ResultScreen
@onready var clock: Control = $Clock
@onready var fight_manager: Node = $FightManager

var grid_arr = []
var game
var rows = 6
var cols = 6
var platform_size = 75
var player_size = 25
var current_player_side = ""
var game_over = false
var difficulty

func _ready():
	player.can_move = false
	game = get_tree().get_first_node_in_group("game")
	setup_grid(rows, cols, platform_size)
	await get_tree().process_frame
	player.grid = grid_arr
	player.platform_size = platform_size
	player.player_size = player_size
	move_player(0, 0)
	player.current_platform = grid_arr[0][0]
	result_screen.visible = false
	set_enemy()
	randomize()
	player.silenced = true
	await get_tree().create_timer(3.0).timeout
	fight_manager.start_fight(difficulty)
	player.can_move = true
	player.silenced = false

func _process(delta):
	if Input.is_action_just_pressed('restart'):
		result_screen._on_restart_pressed()
	
func set_difficulty(difficulty):
	self.difficulty = difficulty
	fight_manager.difficulty = difficulty

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
			padded.set("theme_override_constants/margin_top", size / 4)
			padded.set("theme_override_constants/margin_bottom", size / 4)
			padded.set("theme_override_constants/margin_left", size / 4)
			padded.set("theme_override_constants/margin_right", size / 4)
			grid.add_child(padded)
			row_arr.append(new_platform)
		grid_arr.append(row_arr)
	grid_helper.grid_arr = grid_arr

func move_player(x, y):
	player.global_position = grid_arr[y][x].get_pos() + Vector2(platform_size / 2, platform_size / 2) - Vector2(player_size / 2, player_size / 2)
	player.current_platform = grid_arr[y][x]

func set_enemy():
	var platform_center_offset = Vector2(platform_size / 2, platform_size / 2)
	var a = grid_arr[2][2].get_pos() + platform_center_offset
	var b = grid_arr[2][3].get_pos() + platform_center_offset
	var c = grid_arr[3][2].get_pos() + platform_center_offset
	var d = grid_arr[3][3].get_pos() + platform_center_offset
	enemy.global_position = (a + b + c + d) / 4
	if difficulty == "normal":
		enemy.set_max_hp(350)
	elif difficulty == "savage":
		enemy.set_max_hp(500)
	enemy_hp_bar.max_value = enemy.health
	enemy_hp_bar.value = enemy.health
	enemy_hp_label.text = "Enemy HP: " + str(enemy.health) + "/" + str(enemy.max_health)
	for platform in grid_helper.get_mid_block():
		platform.transition("PlatformBlack", -1)
		platform.set_enemy(true)


func _on_player_health_changed() -> void:
	AudioPlayer.play_FX("hit")
	health_text.text = "Health: " + str(player.health)

func _on_player_dead() -> void:
	result("defeat")

func _on_player_moved() -> void:
	set_player_side()

func set_player_side():
	var x = player.player_x
	var y = player.player_y

	var local_side := "none"
	if x in [0, 1] and y in [2, 3]:
		local_side = "left"
	elif x in [4, 5] and y in [2, 3]:
		local_side = "right"
	elif y in [0, 1] and x in [2, 3]:
		local_side = "top"
	elif y in [4, 5] and x in [2, 3]:
		local_side = "bottom"

	var angle = int(round(rad_to_deg(enemy.rotation))) % 360
	var rotation_map = {
		0: {"top": "front", "bottom": "back",  "left": "left",  "right": "right"},
		90: {"top": "left",  "bottom": "right", "left": "back",  "right": "front"},
		180: {"top": "back",  "bottom": "front", "left": "right", "right": "left"},
		270: {"top": "right", "bottom": "left",  "left": "front", "right": "back"}
	}

	var mapped = rotation_map.get(angle, rotation_map[0])
	current_player_side = mapped.get(local_side, "none")
	print(current_player_side)

func _on_enemy_damage_taken() -> void:
	enemy_hp_bar.value = enemy.health
	enemy_hp_label.text = "Enemy HP: " + str(enemy.health) + "/" + str(enemy.max_health)
	if enemy.weakpoint_side == current_player_side:
		enemy.new_weakpoint()
		enemy.take_damage(enemy.weakpoint_damage)
		AudioPlayer.play_FX("fiora")

func _on_enemy_dead() -> void:
	result("victory")

func result(res):
	game_over = true
	fight_manager.game_over = true
	player.queue_free()
	result_screen.visible = true
	clock.stop()
	result_screen.set_result(res, clock.get_time_formatted(), player.health)
	
func _on_abilities_ability_1_used() -> void:
	if game_over or player.silenced:
		return
	var enemy_hit = false
	for platform in grid_helper.get_sides(player.player_x, player.player_y):
		if platform.is_enemy:
			enemy_hit = true
	if enemy_hit:
		enemy.take_damage(abilities.ability_1_dmg)
		AudioPlayer.play_FX("punch", -15.0)
	player.ability_1()
	AudioPlayer.play_FX("click")

func _on_abilities_ability_2_used() -> void:
	if game_over or player.silenced:
		return
	var enemy_hit = false
	for platform in grid_helper.get_cross(player.player_x, player.player_y):
		if platform.is_enemy:
			enemy_hit = true
	if enemy_hit:
		enemy.take_damage(abilities.ability_2_dmg)
		AudioPlayer.play_FX("punch", -20.0)
	player.ability_2()
	AudioPlayer.play_FX("click")

func _on_abilities_ability_3_used() -> void:
	if game_over or player.silenced:
		return
	player.activate_dash()
	player.ability_3()
	AudioPlayer.play_FX("start_dash")

func _on_abilities_ability_4_used() -> void:
	if game_over or player.silenced:
		return
	player.ability_4()
	AudioPlayer.play_FX("invuln")
