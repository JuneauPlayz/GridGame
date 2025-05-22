extends Control
@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer

var progress_tween

func start(name, length):
	timer.wait_time = length
	timer.start()
	label.text = name
	progress_bar.max_value = 100
	progress_bar.value = 100

	if progress_tween:
		progress_tween.kill()

	progress_tween = create_tween()
	progress_tween.tween_property(progress_bar, "value", 0, length).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	


func _on_timer_timeout() -> void:
	queue_free()
