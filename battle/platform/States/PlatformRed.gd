extends State
class_name PlatformRed

var red = "#cf4848"
@onready var timer: Timer = $Timer

func Enter(length):
	get_parent().get_parent().change_color(red)
	timer.wait_time = length
	timer.start()
	
	
func Update(delta : float):
	pass
	


func _on_timer_timeout() -> void:
	Transitioned.emit(self, "PlatformDefault", -1)
