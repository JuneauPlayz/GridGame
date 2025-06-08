extends Node2D

@export var health = 350
@export var max_health = 350 

signal dead
signal damage_taken

@export var sprite : ColorRect
var weakpoint_side = ""
var weakpoint_damage = 3
@onready var weakpoint: Node2D = $Weakpoint
@onready var cannon: Node2D = $Cannon

var current_weakpoint = null
var current_cannon = null

var fight
var first_weakpoint = true
var grid

func _ready():
	fight = get_parent()
	grid = fight.grid_arr

func take_damage(amt):
	health -= amt
	damage_taken.emit()
	if health <= 0:
		dead.emit()


func set_max_hp(num):
	max_health = num
	health = num

func new_weakpoint():
	if current_weakpoint != null:
		current_weakpoint.ball_weakpoint = false
		
	weakpoint.visible = true
	var num = grid[0].size()
	
	var rand_num = randi_range(0,num-1)
	
	while grid[0][rand_num] == current_weakpoint:
		rand_num = randi_range(0,num-1)
	
	weakpoint.global_position.x = grid[0][rand_num].get_pos().x
	grid[0][rand_num].ball_weakpoint = true
	current_weakpoint = grid[0][rand_num]

func new_cannon_spot():
		
	cannon.visible = true
	var num = grid[0].size()
	
	var rand_num = randi_range(1,num-2)
	
	while rand_num == current_cannon:
		rand_num = randi_range(1,num-2)
	
	cannon.global_position.x = grid[0][rand_num].get_pos().x

	current_cannon = rand_num
