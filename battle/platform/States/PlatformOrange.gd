extends State
class_name PlatformOrange



@onready var flash_timer: Timer = $FlashTimer

func Enter(length):
	get_parent().get_parent().stop_flashing()
	flash_timer.wait_time = length
	flash_timer.start()
	get_parent().get_parent().start_flashing(length * 1.0)

func Exit():
	get_parent().get_parent().stop_flashing()

func Update(delta):
	pass


func _on_flash_timer_timeout() -> void:
	Transitioned.emit(self, "PlatformRed", 1)
