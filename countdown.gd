extends Control
@onready var label: Label = $Label

func _ready():
	label.text = "3"
	await get_tree().create_timer(1.0).timeout
	label.text = "2"
	await get_tree().create_timer(1.0).timeout
	label.text = "1"
	await get_tree().create_timer(1.0).timeout
	queue_free()
