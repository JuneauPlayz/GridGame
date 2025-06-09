extends Node

@onready var grid_helper: Node = $"../Grid/GridHelper"
@onready var player: Node2D = %Player
@onready var enemy: Node2D = $"../Enemy"
@onready var cast_timers: VBoxContainer = %CastTimers
@onready var object_manager: Node = $"../ObjectManager"

const CANNONBALL = preload("res://cannonball.tscn")
const CAST_TIMER = preload("res://cast_timer.tscn")

var current_enemy_rotation = 0
var game_over = false
var difficulty
var fight_num = 0
var fight_paused = true
var last_random_side
var fight

func start_fight(num, difficulty):
	fight = get_parent()
	fight_paused = false
	#AudioPlayer.play_music_level()

	await get_tree().process_frame
	randomize()
	match num:
		1:
			enemy.new_weakpoint()
			if difficulty == "normal":
				normal_1()
			elif difficulty == "savage":
				savage_1()
		2:
			enemy.new_weakpoint()
			if difficulty == "normal":
				normal_2()
			elif difficulty == "savage":
				savage_2()

func normal_1():
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
		await delay(2.0)

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

func savage_1():
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
	attack("inner_ring", 2.0)
	await delay(2.0)
	attack("outer_ring", 1.6)
	await delay(3.0)
	#330 dmg
	start_cast_timer("Whirlwind", 2.5)
	await delay(2.5)
	for i in 4:
		start_cast_timer("Turning Point", 1.0)
		await delay(1.0)
		turning_point()
		random_lr(2.0)
		random_tb(2.0)
		await delay(2.0)
	
	start_cast_timer("Back to Square One", 2.0)
	await delay(2.0)
	rotate_enemy(0)
	
	start_cast_timer("All Out Attack", 2.0)
	await delay(2.0)
	random_lr(1.0)
	await delay(0.7)
	random_lr(1.0)
	await delay(0.7)
	random_lr(1.0)
	await delay(0.7)
	random_lr(1.0)
	await delay(0.7)
	random_lr(1.0)
	await delay(0.7)
	
	await delay(1.0)
	random_tb(1.0)
	await delay(0.7)
	random_tb(1.0)
	await delay(0.7)
	random_tb(1.0)
	await delay(0.7)
	random_tb(1.0)
	await delay(0.7)
	random_tb(1.0)
	await delay(1.75)
	
	inner_outer(10,0.81)
	await delay(10)
	start_cast_timer("Final Finisher (Enrage)", 6.0)
	await delay(6.0)
	while not game_over:
		random_side(0.3)
		await delay(0.1)

func normal_2():
	#var starting_blue = grid_helper.get_offset(grid_helper.get_corner("top_right"), -1, 1)
	#starting_blue.transition("PlatformBlue", 3)
	#await delay(0.2)
	#var next_blue = grid_helper.get_offset(starting_blue, 1, 4)
	#next_blue.transition("PlatformBlue", 3)
	#await delay(0.2)
	#next_blue = grid_helper.get_offset(next_blue, -4, 1)
	#next_blue.transition("PlatformBlue", 3)
	
	for i in 3:
		fight.enemy.new_cannon_spot()
		fire_cannonball(3.0)
		await delay(3.0)
		create_blue(3.0)
		await delay(1.5)
		create_blue(3.0)
		await delay(8)
	
	pass
	
func savage_2():
	pass

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
			platform.transition("PlatformRed", 0.15)
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
	rotate_enemy(current_enemy_rotation + choice)
	
func rotate_enemy(deg):
	enemy.rotation = deg_to_rad(deg)
	current_enemy_rotation = deg
	fight.set_player_side()

func create_blue(cast_timer):
	start_cast_timer("Create: Blue", cast_timer)
	await delay(cast_timer)
	player.current_platform.transition("PlatformBlue", 6)
	
func root_player(mode):
	player.can_move = mode

func spawn_cannonball(x,y, from_ship := false):
	var new_object = CANNONBALL.instantiate()
	object_manager.add_child(new_object)
	new_object.grid = fight.grid_arr
	new_object.platform_size = fight.platform_size
	if from_ship:
		new_object.move_to(fight.enemy.current_cannon, 1)
	new_object.move_to(x,y)
	new_object.fight = fight
	new_object.weakpoint_hit.connect(on_weakpoint_hit)
	new_object.ship_hit.connect(on_ship_hit)
	return new_object
	
func drop_cannonball(x,y,cast_timer):
	start_cast_timer("Drop Cannonball", 2.5)
	await delay(2.5)
	spawn_cannonball(x,y)

func fire_cannonball(cast_timer):
	start_cast_timer("Cannon Shoot", 2.5)
	await delay(2.5)
	var col = fight.enemy.current_cannon
	for i in range(col-1, col+2):
		if i < grid_helper.get_grid().size():
			for platform in grid_helper.get_col(i):
				platform.transition("PlatformOrange", 1)
	await delay(1)
	spawn_cannonball(col, randi_range(5,6), true)

func fire_mini_cannonball():
	var cannonball = spawn_cannonball(4,4)
	cannonball.knock_back("top", 10)
	
func the_world(cast_timer, length):
	start_cast_timer("time stop", cast_timer)
	await delay(cast_timer)
	player.can_move = false
	player.effect("rooted!", length)
	await delay(length)
	player.can_move = true

func on_weakpoint_hit():
	fight.weakpoint_hit()

func on_ship_hit():
	fight.ship_hit()

func start_cast_timer(name, length):
	if game_over:
		return
	var new_cast_timer = CAST_TIMER.instantiate()
	new_cast_timer.call_deferred("start", name, length)
	cast_timers.add_child(new_cast_timer)

func delay(time) -> void:
	await get_tree().create_timer(time).timeout
