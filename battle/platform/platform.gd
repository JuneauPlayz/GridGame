extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var state_machine: Node = $"State Machine"
@onready var color_rect_2: ColorRect = $ColorRect2
@onready var up: Node2D = $Weakpoints/Up
@onready var right: Node2D = $Weakpoints/Right
@onready var down: Node2D = $Weakpoints/Down
@onready var left: Node2D = $Weakpoints/Left

var grid_x
var grid_y

var orange = Color("#bf5a1b90")
var white = Color("#616161")

var is_enemy = false
var activation = false

var ball_weakpoint = false
var flash_tween
var fight

var curr_player_dir = null

var old_weakpoints = []
var weakpoints = []

signal weakpoint_effect

func _ready():
	fight = get_tree().get_first_node_in_group("fight")
	set_process(false)
	
func _process(delta):
	if not fight or not fight.player:
		return

	var directions = [
		Vector2i(0, -1),  # Up
		Vector2i(0, 1),   # Down
		Vector2i(-1, 0),  # Left
		Vector2i(1, 0)    # Right
	]

	for dir in directions:
		var check_x = self.grid_x + dir.x
		var check_y = self.grid_y + dir.y

		# Bounds check
		if check_y < 0 or check_y >= fight.grid_arr.size():
			continue
		if check_x < 0 or check_x >= fight.grid_arr[0].size():
			continue

		if check_x == fight.player.x and check_y == fight.player.y:
			match dir:
				Vector2i(0, -1):
					curr_player_dir = "up"
				Vector2i(0, 1):
					curr_player_dir = "down"
				Vector2i(-1, 0):
					curr_player_dir = "left"
				Vector2i(1, 0):
					curr_player_dir = "right"
			
			# do something here
	
func set_size(width, height):
	var base_size = 50.0  # Define the original base size of the platform
	var scale_x = width / base_size
	var scale_y = height / base_size
	self.scale = Vector2(scale_x, scale_y)

func get_pos():
	return color_rect.global_position

func change_color(color):
	color_rect.color = color

func transition(state, length):
	state_machine.set_state(state, length)

func start_flashing(length):
	_flash_sequence(length)

func stop_flashing():
	if flash_tween:
		flash_tween.kill()
	flash_tween = null


func _flash_sequence(length) -> void:
	stop_flashing()
	var steps = 5  # 3 full flashes = 6 transitions (white→orange→white→...)
	var time_per_step = length / steps * 1.0
	
	color_rect.color = white
	var colors = [orange, white, orange, white, orange]

	await get_tree().process_frame

	for color in colors:
		flash_tween = create_tween()
		flash_tween.tween_property(color_rect, "color", color, time_per_step).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await flash_tween.finished
		
func get_state():
	return state_machine.current_state

func set_enemy(x):
	transition("PlatformBlack", -1)
	is_enemy = x
	self.visible = false
	
func get_side(x, y) -> String:
	var dx = x - grid_x
	var dy = y - grid_y

	match [dx, dy]:
		[0, -1]: return "top"
		[1, -1]: return "top_right"
		[-1, -1]: return "top_left"
		[-1, 0]: return "left"
		[1, 0]: return "right"
		[0, 1]: return "bottom"
		[-1, 1]: return "bottom_left"
		[1, 1]: return "bottom_right"
		[0, 0]: return "same"
		_: return "unknown"

func get_player_side():
	return get_side(fight.player.x, fight.player.y)

func set_activation(x, sides):
	activation = x
	set_process(x)
	weakpoints = sides
	old_weakpoints = sides.duplicate()
	show_weakpoints()

func show_weakpoints():
	for weakpoint in weakpoints:
		match weakpoint:
			"up":
				up.visible = true
			"left":
				left.visible = true
			"right":
				right.visible = true
			"down":
				down.visible = true

func toggle_weakpoints(x):
	weakpoints.visible = x
	weakpoints.clear()

func new_weakpoints():
	weakpoints = old_weakpoints.duplicate()
	weakpoint_effect.emit()
	show_weakpoints()

				
func remove_weakpoint(side):
	weakpoints.erase(side)
	match side:
			"up":
				up.visible = false
			"left":
				left.visible = false
			"right":
				right.visible = false
			"down":
				down.visible = false
	AudioPlayer.play_FX("fiora")
