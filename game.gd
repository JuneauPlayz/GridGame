extends Node2D

var current_scene = null
const FIGHT_TEST = preload("res://battle/fight_test.tscn")

func _ready():
	new_scene(FIGHT_TEST)
	
func new_scene(scene):
	var new_scn = scene.instantiate()
	self.add_child(new_scn)
	current_scene = new_scn
	
