extends Node2D

@onready var grid: GridContainer = $Grid

const PLATFORM = preload("res://battle/platform/platform.tscn")
const ENEMY_2 = preload("res://enemy_2.tscn")

@onready var grid_helper: Node = $Grid/GridHelper
@onready var player: Node2D = $Player
@onready var enemy: Node2D = $Enemy
@onready var fight_manager: Node = $FightManager
@onready var countdown: Control = %Countdown
@onready var clock: Control = %Clock
@onready var abilities: Control = %Abilities
@onready var result_screen: Node2D = %ResultScreen
@onready var cast_timers: VBoxContainer = %CastTimers
@onready var enemy_hp_bar: ProgressBar = %EnemyHPBar
@onready var enemy_hp_label: Label = %EnemyHPLabel
@onready var health_text: Label = %HealthText
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var object_manager: Node = $ObjectManager
@onready var background: ColorRect = $Camera2D/Background

var grid_arr = []
var game
var rows = 6
var cols = 6
var platform_size = 75
var player_size = 25
var current_player_side = ""
var game_over = false
var difficulty
var fight_num = 0

func _ready():
	player.can_move = false
	game = get_tree().get_first_node_in_group("game")
	await get_tree().process_frame
	result_screen.visible = false
	set_enemy()
	randomize()
	player.silenced = true
	await get_tree().create_timer(3.0).timeout
	fight_manager.start_fight(fight_num, difficulty)
	player.can_move = true
	player.silenced = false

func _process(delta):
	if Input.is_action_just_pressed('restart'):
		result_screen._on_restart_pressed()
	elif Input.is_action_just_pressed('main_menu'):
		game.new_scene(game.START_SCREEN)

func set_fight(num, difficulty):
	self.difficulty = difficulty
	fight_manager.difficulty = difficulty
	game.difficulty = difficulty
	fight_num = num
	fight_manager.fight_num = num
	game.fight_num = num
	match num:
		1:
			rows = 6
			cols = 6
			platform_size = 75
			setup_grid(rows, cols, platform_size)
			player.call_deferred("move_player", 0, 0)
		2:
			rows = 9
			cols = 9
			platform_size = 60
			setup_grid(rows, cols, platform_size)
			change_enemy(ENEMY_2)
			player.call_deferred("move_player", 0, 4)
			change_bg_color("#4b95a6")

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
			new_platform.grid_x = j
			new_platform.grid_y = i
			var padded = MarginContainer.new()
			padded.add_child(new_platform)
			padded.set("theme_override_constants/margin_top", size / 4)
			padded.set("theme_override_constants/margin_bottom", size / 4)
			padded.set("theme_override_constants/margin_left", size / 4)
			padded.set("theme_override_constants/margin_right", size / 4)
			grid.add_child(padded)
			row_arr.append(new_platform)
			new_platform.fight = self
		grid_arr.append(row_arr)
	grid_helper.grid_arr = grid_arr
	player.grid = grid_arr
	player.platform_size = platform_size
	player.player_size = player_size
	player.current_platform = grid_arr[0][0]
	


func set_enemy():
	match fight_num:
		1:
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

			for platform in grid_helper.get_mid_block():
				platform.set_enemy(true)
		2:
			for platform in grid_helper.get_row(0):
				platform.set_enemy(true)
				
			for platform in grid_helper.get_row(1):
				platform.set_enemy(true)
				
			for platform in grid_helper.get_row(2):
				platform.transition("PlatformBlack", -1)
				platform.visible = false
			for platform in grid_helper.get_row(3):
				platform.transition("PlatformBlack", -1)
				platform.visible = false
			for platform in grid_helper.get_row(8):
				platform.transition("PlatformBlack", -1)
				platform.visible = false
			grid_arr[4][4].transition("PlatformBlack", -1)
			grid_arr[4][4].set_activation(true, ["left", "down", "right"])
			grid_arr[4][4].weakpoint_effect.connect(fight_manager.fire_mini_cannonball)
			enemy.global_position = grid_helper.get_corner("top_left").get_pos()
			enemy.global_position.x = (get_viewport_rect().size.x - enemy.sprite.size.x) / 2
	enemy_hp_bar.max_value = enemy.health
	enemy_hp_bar.value = enemy.health
	enemy_hp_label.text = "Enemy HP: " + str(enemy.health) + "/" + str(enemy.max_health)

func _on_player_health_changed() -> void:
	AudioPlayer.play_FX("hit")
	health_text.text = "Health: " + str(player.health)

func _on_player_dead() -> void:
	result("defeat")

func _on_player_moved() -> void:
	set_player_side()

func set_player_side():
	if not player:
		return
	var x = player.x
	var y = player.y

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
		weakpoint_hit()
		
func weakpoint_hit():
	enemy.new_weakpoint()
	enemy.take_damage(enemy.weakpoint_damage)
	AudioPlayer.play_FX("fiora")

func ship_hit():
	enemy.take_damage(5)
	AudioPlayer.play_FX("hit", -10)

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
	player.ability_1()
	hit_check(grid_helper.get_sides(player.x, player.y), abilities.ability_1_dmg)
	AudioPlayer.play_FX("click")

func _on_abilities_ability_2_used() -> void:
	if game_over or player.silenced:
		return
	hit_check(grid_helper.get_cross(player.x, player.y), abilities.ability_2_dmg)
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

func hit_check(platforms, dmg):
	var enemy_hit = false
	for platform in platforms:
		if platform.is_enemy:
			enemy_hit = true
		if platform.activation == true:
			if platform.curr_player_dir in platform.weakpoints:
				platform.remove_weakpoint(platform.curr_player_dir)
				if platform.weakpoints.is_empty():
					platform.new_weakpoints()
	if enemy_hit:
		enemy.take_damage(dmg)
		AudioPlayer.play_FX("punch", -15.0)

func change_enemy(scene):
	if enemy != null:
		enemy.queue_free()
	enemy = scene.instantiate()
	self.add_child(enemy)
	fight_manager.enemy = enemy
	enemy.damage_taken.connect(_on_enemy_damage_taken)
	enemy.dead.connect(_on_enemy_dead)

func change_bg_color(color):
	background.color = color
