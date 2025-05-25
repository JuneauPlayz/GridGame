extends Node2D

var game

@onready var result_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Result
@onready var time_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Time
@onready var health_left: Label = $PanelContainer/MarginContainer/VBoxContainer/HealthLeft

func _ready():
	game = get_tree().get_first_node_in_group("game")

func _on_main_menu_pressed() -> void:
	game.new_scene(game.START_SCREEN)


func _on_restart_pressed() -> void:
	var fight = game.new_scene(game.FIGHT_TEST)
	fight.start_fight(game.difficulty)

func set_result(result, time, health):
	match result:
		"victory":
			result_label.text = "Victory!"
			health_left.visible = true
			health_left.text = "Health Left: " + str(health)
		"defeat":
			result_label.text = "Defeated.."
			health_left.visible = false
	time_label.text = "Time: " + time 
			
