extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var state_machine: Node = $"State Machine"


var orange = Color("#bf5a1b75")
var white = Color("#616161")

var is_enemy = false

var flash_tween

func set_size(width, length):
	color_rect.custom_minimum_size = Vector2(width, length)
	color_rect.size = Vector2(width, length)

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
	is_enemy = x
