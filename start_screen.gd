extends Node2D

var game

func _ready():
	game = get_tree().get_first_node_in_group("game")

func _on_normal_pressed() -> void:
	var fight = game.new_scene(game.FIGHT_TEST)
	fight.start_fight("normal")
	game.difficulty = "normal"

func _on_savage_pressed() -> void:
	pass # Replace with function body.
