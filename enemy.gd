extends Node2D

@export var health = 300
@export var max_health = 300
@onready var weakpoint: Node2D = $Weakpoint


signal dead
signal damage_taken

var weakpoint_side = ""
var weakpoint_damage = 5

func take_damage(amt):
	health -= amt
	damage_taken.emit()
	if health <= 0:
		dead.emit()

func set_weakpoint(side):
	match side:
		"front":
			weakpoint.rotation = deg_to_rad(270)
		"back":
			weakpoint.rotation = deg_to_rad(90)
		"left":
			weakpoint.rotation = deg_to_rad(180)
		"right":
			weakpoint.rotation = deg_to_rad(0)

func new_weakpoint():
	var sides = ["front", "back", "left", "right"]
	sides.erase(weakpoint_side)  # Remove the current side
	var new_side = sides[randi() % sides.size()]
	set_weakpoint(new_side)
	weakpoint_side = new_side
	print("enemy " + weakpoint_side)
