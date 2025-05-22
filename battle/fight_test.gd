extends Node2D

@onready var grid: GridContainer = $Grid
const PLATFORM = preload("res://battle/platform/platform.tscn")
@onready var grid_helper: Node = $Grid/GridHelper
const CAST_TIMER = preload("res://cast_timer.tscn")
@onready var player: Node2D = $Player
@onready var cast_timers: VBoxContainer = $CastTimers
@onready var health_text: Label = $Camera2D/CanvasLayer/HealthText

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

	#await get_tree().create_timer(0.5).timeout
	#await lefty(2.0)
	#await get_tree().create_timer(0.5).timeout
	#await righty(2.0)
	#await get_tree().create_timer(0.5).timeout
	#await uppercut(2.0)
	#await get_tree().create_timer(0.5).timeout
	#await low_blow(2.0)

	await get_tree().create_timer(2.0).timeout
	lefty(2.0)
	await get_tree().create_timer(1.75).timeout
	righty(2.0)
	await get_tree().create_timer(1.75).timeout
	lefty(2.0)
	await get_tree().create_timer(3).timeout
	start_cast_timer("Fakeout", 2.0)
	await get_tree().create_timer(2.5).timeout
	fakeout_lefty(2.0)
	await get_tree().create_timer(3).timeout
	start_cast_timer("Fakeout", 2.0)
	await get_tree().create_timer(2.5).timeout
	fakeout_uppercut(2.0)
		
func lefty(cast_time):
	start_cast_timer("Lefty", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("left"):
		platform.transition("PlatformOrange",1)

func fakeout_lefty(cast_time):
	start_cast_timer("Lefty", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("right"):
		platform.transition("PlatformOrange",1)
	
func righty(cast_time):
	start_cast_timer("Righty", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("right"):
		platform.transition("PlatformOrange",1)

func fakeout_righty(cast_time):
	start_cast_timer("Righty", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("left"):
		platform.transition("PlatformOrange",1)

func uppercut(cast_time):
	start_cast_timer("Uppercut", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("top"):
		platform.transition("PlatformOrange",1)

func fakeout_uppercut(cast_time):
	start_cast_timer("Uppercut", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("bottom"):
		platform.transition("PlatformOrange",1)
		
func low_blow(cast_time):
	start_cast_timer("Low Blow", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("bottom"):
		platform.transition("PlatformOrange",1)

func fakeout_low_blow(cast_time):
	start_cast_timer("Low Blow", cast_time)
	await get_tree().create_timer(cast_time).timeout
	for platform in grid_helper.get_half("top"):
		platform.transition("PlatformOrange",1)
		

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
