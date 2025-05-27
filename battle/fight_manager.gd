extends Node

@onready var grid_helper: Node = $"../Grid/GridHelper"
@onready var player: Node2D = $"../Player"
@onready var cast_timers: VBoxContainer = $"../CastTimers"
@onready var enemy: Node2D = $"../Enemy"

const CAST_TIMER = preload("res://cast_timer.tscn")

var current_enemy_rotation = 0
var game_over = false
var difficulty
var fight_paused = true
var last_random_side
var fight

func start_fight(difficulty):
	fight = get_parent()
	fight_paused = false
	AudioPlayer.play_music_level()
	player.global_position = grid_helper.grid_arr[0][0].get_pos()
	player.current_platform = grid_helper.grid_arr[0][0]
	enemy.new_weakpoint()

	await get_tree().process_frame
	randomize()
	player.global_position = grid_helper.grid_arr[0][0].get_pos()
	if difficulty == "normal":
		normal()
	elif difficulty == "savage":
		savage()

func normal():
	await delay(1.0)
	await attack("lefty", 2.0)
	await delay(3.0)
	await attack("righty", 2.0)
	await delay(3.0)
	await attack("uppercut", 2.0)
	await delay(3.0)
	await attack("low_blow", 2.0)
	await delay(3.0)
	await attack("lefty", 2.0)
	await delay(1.5)
	await attack("righty", 2.0)
	await delay(1.5)
	await attack("lefty", 2.0)
	await delay(3.0)
	await attack("inner_ring", 2.0)
	await delay(3.0)
	await attack("outer_ring", 2.0)
	await delay(3.0)
	await attack("outer_ring", 2.0)
	await attack("lefty", 2.0)
	await delay(3.5)
	await attack("righty", 2.0)
	await attack("uppercut", 2.0)
	await delay(3.5)
	start_cast_timer("Fakeout", 2.0)
	await delay(2.5)
	await attack("lefty", 2.0, true)
	await delay(3.5)
	
	start_cast_timer("Barrage", 2.0)
	for i in 8:
		random_side(2.0)
		await delay(1.0)

	start_cast_timer("Turning Point", 2.0)
	await delay(2.0)
	
	rotate_enemy(90)
	await delay(1.0)
	await attack("lefty", 2.0)
	await delay(3.0)
	await attack("uppercut", 2.0)
	await delay(3.0)
	start_cast_timer("Fakeout", 2.0)
	await delay(2.0)
	await attack("righty", 2.0, true)
	await delay(2.0)
	

	while not game_over:
		start_cast_timer("Turning Point", 2.0)
		await delay(2.0)
		rotate_enemy(current_enemy_rotation + 90)
		await delay(1.0)
		random_double(2.0)
		await delay(3.0)
		random_side(2.0)
		await attack("inner_ring", 2.0)
		await delay(3.0)
		random_double(2.0)
		await delay(2.0)
		random_side(2.0)
		await attack("outer_ring", 2.0)
		await delay(2.0)

func savage():
	var last_h
	var last_v
	
	# each half
	last_h = random_lr(2.0)
	await delay(2.0)
	if last_h == "lefty":
		attack("righty", 2.0)
	else:
		attack("lefty", 2.0)
	
	await delay(2.0)
	
	last_v = random_tb(2.0)
	await delay(2.0)
	if last_v == "uppercut":
		attack("low_blow", 2.0)
	else:
		attack("uppercut", 2.0)
	
	await delay(2.0)
	attack("inner_ring", 2.0)
	await delay(1.0)
	attack("outer_ring", 2.0)

	await delay(3.0)
	
	random_combo(3.0)
	await delay(5.0)
	start_cast_timer("Fakeout", 2.0)
	await delay(2.0)
	random_combo(3.0, true)
	await delay(5.0)
	start_cast_timer("Barrage", 2.0)
	await delay(2.0)
	for i in 6:
		random_side(2.0)
		await delay(1.0)
	
	await delay(3.0)
	start_cast_timer("Turning Point", 2.5)
	await delay(2.5)
	turning_point()
	
	random_side(2.0)
	await delay(2.0)
	random_side(2.0)
	await delay(3.0)
	
	start_cast_timer("Barrage", 2.0) 
	await delay(2.0)
	for i in 6:
		random_side(2.0)
		await delay(1.0)
		
	 #260 dmg
	await delay(2.0)
	start_cast_timer("Carousel", 2.0)
	await delay(2.0)
	inner_outer(8)
	circle(8)
	
	await delay(15.0)
	
	start_cast_timer("Turning Point", 2.5)
	await delay(2.5)
	turning_point()
	await delay(1.0)
	random_combo(2.5)
	await delay(1.0)
	attack("inner_ring", 1.5)
	await delay(2.0)
	attack("outer_ring", 1.6)
	
	#315 dmg
	
func attack(name: String, cast_time: float, fakeout := false):
	if game_over:
		return
	var mapped_attack = get_mapped_attack(name, fakeout)
	start_cast_timer(name.capitalize(), cast_time)
	await get_tree().create_timer(cast_time).timeout

	var targets = []
	match mapped_attack:
		"left": targets = grid_helper.get_half("left")
		"right": targets = grid_helper.get_half("right")
		"top": targets = grid_helper.get_half("top")
		"bottom": targets = grid_helper.get_half("bottom")
		"outer_ring": targets = grid_helper.get_outer_ring()
		"inner_ring": targets = grid_helper.get_middle_ring()
	
	if difficulty == "normal":
		for platform in targets:
			platform.transition("PlatformOrange", 1)
		await get_tree().create_timer(1).timeout
		AudioPlayer.play_FX("punch")
	elif difficulty == "savage":
		for platform in targets:
			platform.transition("PlatformRed", 0.25)
		AudioPlayer.play_FX("punch")

func get_mapped_attack(name: String, fakeout: bool) -> String:
	var angle = int(round(rad_to_deg(enemy.rotation))) % 360
	if angle % 90 != 0:
		angle = 0

	var map = {
		"lefty": ["left", "right"],
		"righty": ["right", "left"],
		"uppercut": ["top", "bottom"],
		"low_blow": ["bottom", "top"]
	}

	var direction = map.get(name, name)
	if direction is String:
		return direction

	var primary = direction[0]
	var fake = direction[1]

	var rotation_to_direction = {
		0: {"left": "left", "right": "right", "top": "top", "bottom": "bottom"},
		90: {"left": "top", "right": "bottom", "top": "right", "bottom": "left"},
		180: {"left": "right", "right": "left", "top": "bottom", "bottom": "top"},
		270: {"left": "bottom", "right": "top", "top": "left", "bottom": "right"}
	}

	var rot_map = rotation_to_direction.get(angle, rotation_to_direction[0])
	return rot_map[fake] if fakeout else rot_map[primary]

func random_side(cast_time):
	var atk1 = [
		["attack", "lefty", cast_time],
		["attack", "righty", cast_time],
		["attack", "uppercut", cast_time],
		["attack", "low_blow", cast_time]
	]
	var choice = atk1.pick_random()
	while choice[1] == last_random_side:
		choice = atk1.pick_random()
	call(choice[0], choice[1], choice[2])
	last_random_side = choice[1]

func random_lr(cast_time):
	var atk1 = [
		["attack", "lefty", cast_time],
		["attack", "righty", cast_time],
	]
	var choice = atk1.pick_random()
	call(choice[0], choice[1], choice[2])
	return choice[1]

func random_tb(cast_time):
	var atk1 = [
		["attack", "uppercut", cast_time],
		["attack", "low_blow", cast_time],
	]
	var choice = atk1.pick_random()
	call(choice[0], choice[1], choice[2])
	return choice[1]

func random_combo(cast_time, fakeout := false):
	var combos = ["RLR", "LRL"]
	var choice = combos.pick_random()
	match choice:
		"RLR":
			start_cast_timer("RLR Combo", cast_time)
			await delay(cast_time)
			await attack("righty", 0.5, fakeout)
			await delay(0.3)
			await attack("lefty", 0.5)
			await delay(0.3)
			await attack("righty", 0.5)
		"LRL":
			start_cast_timer("LRL Combo", cast_time)
			await delay(cast_time)
			await attack("lefty", 0.5, fakeout)
			await delay(0.3)
			await attack("righty", 0.5)
			await delay(0.3)
			await attack("lefty", 0.5)
			
func inner_outer(times, cast_time := 1.5):
	var first_attack = true
	for i in times/2:
		if first_attack:
			attack("outer_ring", cast_time + 1.0)
			first_attack = false
			await delay(1.0)
		else:
			attack("outer_ring",cast_time)
		await delay(cast_time)
		attack("inner_ring", cast_time)
		await delay(cast_time)
		
func circle(times, cast_time := 1.5):
	var first_attack = true
	var hits_left = times
	while true:
		if hits_left <= 0:
			break
		if first_attack:
			attack("lefty", cast_time + 1.0)
			first_attack = false
			await delay(1.0)
		else:
			attack("lefty", cast_time)
		await delay(cast_time)
		hits_left -= 1
		if hits_left <= 0:
			break
		attack("uppercut", cast_time)
		await delay(cast_time)
		hits_left -= 1
		if hits_left <= 0:
			break
		attack("righty", cast_time)
		await delay(cast_time)
		hits_left -= 1
		if hits_left <= 0:
			break
		attack("low_blow", cast_time)
		await delay(cast_time)
		hits_left -= 1
func random_double(cast_time):
	var sides = ["lefty", "righty"]
	var verticals = ["uppercut", "low_blow"]
	call("attack", sides.pick_random(), cast_time)
	call("attack", verticals.pick_random(), cast_time)

func turning_point():
	var rotations = [90, 180, 270]
	var choice = rotations.pick_random()
	rotate_enemy(choice)
	
func rotate_enemy(deg):
	enemy.rotation = deg_to_rad(deg)
	current_enemy_rotation = deg
	fight.set_player_side()

func start_cast_timer(name, length):
	if game_over:
		return
	var new_cast_timer = CAST_TIMER.instantiate()
	new_cast_timer.call_deferred("start", name, length)
	cast_timers.add_child(new_cast_timer)

func delay(time) -> void:
	await get_tree().create_timer(time).timeout
