extends Node2D

@export var health = 350
@export var max_health = 350
@onready var weakpoint: Node2D = $Weakpoint


signal dead
signal damage_taken

var weakpoint_side = ""
var weakpoint_damage = 3

var first_weakpoint = true

func _ready():
	weakpoint.visible = false
	
func take_damage(amt):
	health -= amt
	damage_taken.emit()
	if health <= 0:
		dead.emit()

func set_weakpoint(side):
	if weakpoint.visible == false:
		weakpoint.visible = true
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
	var sides
	if not first_weakpoint:
		sides = ["front", "back", "left", "right"]
	else:
		sides = ["front", "left"]
		first_weakpoint = false
	sides.erase(weakpoint_side)  # Remove the current side
	var new_side = sides[randi() % sides.size()]
	set_weakpoint(new_side)
	weakpoint_side = new_side
	print("enemy " + weakpoint_side)

func set_max_hp(num):
	max_health = num
	health = num
