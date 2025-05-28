extends Control

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer

func start(length):
	# Set the progress bar range and full value
	texture_progress_bar.min_value = 0
	texture_progress_bar.max_value = 100
	texture_progress_bar.value = 100

	# Start the timer
	timer.wait_time = length
	timer.start()

	# Animate the bar visually from full to 0
	var tween = create_tween()
	tween.tween_property(texture_progress_bar, "value", 0, length).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func _on_timer_timeout() -> void:
	pass # Replace with function body.
