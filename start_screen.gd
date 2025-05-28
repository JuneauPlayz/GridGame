extends Node2D

var game

func _ready():
	game = get_tree().get_first_node_in_group("game")

func _on_normal_pressed() -> void:
	var fight = game.new_scene(game.FIGHT_TEST)
	fight.set_fight(1, "normal")
	game.difficulty = "normal"

func _on_savage_pressed() -> void:
	var fight = game.new_scene(game.FIGHT_TEST)
	fight.set_fight(1, "savage")
	game.difficulty = "savage"


func _on_normal_2_pressed() -> void:
	var fight = game.new_scene(game.FIGHT_TEST)
	fight.set_fight(2, "normal")
	game.difficulty = "normal"
