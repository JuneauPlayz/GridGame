extends Node2D

var current_scene = null
var difficulty = ""
var fight_num = 0

const FIGHT_TEST = preload("res://battle/fight_test.tscn")
const START_SCREEN = preload("res://start_screen.tscn")

var movement_type = 1

func _ready():
	new_scene(START_SCREEN)
	
func new_scene(scene):
	if current_scene != null:
		current_scene.queue_free()
	var new_scn = scene.instantiate()
	self.add_child(new_scn)
	current_scene = new_scn
	return current_scene
