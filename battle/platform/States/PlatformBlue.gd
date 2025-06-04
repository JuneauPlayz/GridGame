extends State
class_name PlatformBlue

var blue = "#2b8ccc"
@onready var timer: Timer = $Timer
var fight
const CIRCULAR_TIMER = preload("res://circular_timer.tscn")
var circular_timer

var grid_x
var grid_y

var player_x
var player_y
func Enter(length):
	fight = get_parent().get_parent().fight
	await get_tree().process_frame
	get_parent().get_parent().change_color(blue)
	circular_timer = CIRCULAR_TIMER.instantiate()
	circular_timer.scale = Vector2(0.2,0.2)
	circular_timer.visible = true
	circular_timer.call_deferred("start", length)
	fight = get_parent().get_parent().fight
	fight.canvas_layer.add_child(circular_timer)
	var scaled_size = 1024 * 0.2 * 0.18
	var offset = (fight.platform_size - scaled_size) / 2
	circular_timer.global_position = get_parent().get_parent().global_position + Vector2(fight.platform_size/2-2, fight.platform_size/2-1)
	timer.wait_time = length
	timer.start()
	#circular_timer.rect_position = Vector2((fight.platform_size - circular_timer.rect_size.x)/2, (fight.platform_size - circular_timer.rect_size.y)/2)

	
func Update(delta : float):
	pass
	


func _on_timer_timeout() -> void:
	circular_timer.visible = false
	var side = get_parent().get_parent().get_player_side()
	fight.player.knock_back(side, 3)
	for object in fight.object_manager.get_children():
		object.knock_back(get_parent().get_parent().get_side(object.x, object.y), 3)
	Transitioned.emit(self, "PlatformDefault", -1)
