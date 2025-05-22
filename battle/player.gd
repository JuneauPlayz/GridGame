extends Node2D

var grid
var platform_size
var player_size

@onready var invuln_timer: Timer = $InvulnTimer
@onready var sprite: ColorRect = $ColorRect
var tween

var current_platform
var player_x = 0
var player_y = 0
var is_moving = false
var is_invuln = false
var health = 3

signal health_changed

var last_move = "none"

func _ready():
	player_size = sprite.size.x

func _process(delta):
	if Input.is_action_just_pressed("up"):
		if player_y > 0:
			if grid[player_y-1][player_x].get_state() is not PlatformBlack:
				player_y -= 1
				move_player(player_x, player_y)

	if Input.is_action_just_pressed("down"):
		if player_y < grid.size() - 1:
			if grid[player_y+1][player_x].get_state() is not PlatformBlack:
				player_y += 1
				move_player(player_x, player_y)

	if Input.is_action_just_pressed("left"):
		if player_x > 0:
			if grid[player_y][player_x-1].get_state() is not PlatformBlack:
				player_x -= 1
				move_player(player_x, player_y)

	if Input.is_action_just_pressed("right"):
		if player_x < grid[0].size() - 1:
			if grid[player_y][player_x+1].get_state() is not PlatformBlack:
				player_x += 1
				move_player(player_x, player_y)
	
	if current_platform.get_state() is PlatformRed and is_invuln == false:
		take_damage(1)
		
func move_player(x, y):
	var target_pos = grid[y][x].get_pos() + Vector2(platform_size/2, platform_size/2) - Vector2(player_size/2, player_size/2)
	tween = create_tween()
	is_moving = true
	tween.tween_property(self, "global_position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	is_moving = false
	current_platform = grid[y][x]

func take_damage(amt):
	lose_health(amt)
	invuln_timer.start()
	is_invuln = true
	
func lose_health(amt):
	health -= amt
	health_changed.emit()


func _on_invuln_timer_timeout() -> void:
	is_invuln = false
