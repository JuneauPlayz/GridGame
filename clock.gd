extends Control

@onready var minutes_label: Label = $Panel/HBoxContainer/Minutes
@onready var seconds_label: Label = $Panel/HBoxContainer/Seconds

@onready var fight_manager: Node = $"../FightManager"

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0
func _process(delta) -> void:
	if fight_manager.fight_paused == true:
		return
	time += delta
	msec = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	
	minutes_label.text = "%02d: " % minutes
	seconds_label.text = "%02d" % seconds

func stop() -> void:
	set_process(false)
	
func get_time_formatted() -> String:
	return "%02d:%02d.%03d" % [minutes, seconds, msec]
