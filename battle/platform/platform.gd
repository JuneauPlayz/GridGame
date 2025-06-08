extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var state_machine: Node = $"State Machine"
@onready var color_rect_2: ColorRect = $ColorRect2

var grid_x
var grid_y

var orange = Color("#bf5a1b75")
var white = Color("#616161")

var is_enemy = false

var ball_weakpoint = false
var flash_tween
var fight


func _ready():
	fight = get_tree().get_first_node_in_group("fight")
	
func set_size(width, length):
	color_rect.custom_minimum_size = Vector2(width, length)
	color_rect.size = Vector2(width, length)
	color_rect_2.custom_minimum_size = Vector2(width+4, length+4)
	color_rect_2.size = Vector2(width+4, length+4)

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
