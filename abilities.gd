extends Control

@onready var ability_1_bar: ProgressBar = $HBoxContainer/Ability1/ProgressBar
@onready var ability_2_bar: ProgressBar = $HBoxContainer/Ability2/ProgressBar2
@onready var ability_3_bar: ProgressBar = $HBoxContainer/Ability3/ProgressBar3
@onready var ability_4_bar: ProgressBar = $HBoxContainer/Ability4/ProgressBar4


@onready var timer1: Timer = $HBoxContainer/Ability1/Timer
@onready var timer2: Timer = $HBoxContainer/Ability2/Timer2
@onready var timer3: Timer = $HBoxContainer/Ability3/Timer3
@onready var timer4: Timer = $HBoxContainer/Ability4/Timer4

@onready var time_left_1: Label = $HBoxContainer/Ability1/ProgressBar/Label
@onready var time_left_2: Label = $HBoxContainer/Ability2/ProgressBar2/Label2
@onready var time_left_3: Label = $HBoxContainer/Ability3/ProgressBar3/Label3
@onready var time_left_4: Label = $HBoxContainer/Ability4/ProgressBar4/Label4

var cooldown_1 = 1.5
var cooldown_2 = 5.0
var cooldown_3 = 10.0
var cooldown_4 = 20.0

var ability_1_ready = true
var ability_2_ready = true
var ability_3_ready = true
var ability_4_ready = true

signal ability_1_used
signal ability_2_used
signal ability_3_used
signal ability_4_used

var ability_1_dmg = 3
var ability_2_dmg = 10

func _ready():
	# Initialize bars and timers
	_init_ability(ability_1_bar, timer1, cooldown_1)
	_init_ability(ability_2_bar, timer2, cooldown_2)
	_init_ability(ability_3_bar, timer3, cooldown_3)
	_init_ability(ability_4_bar, timer4, cooldown_4)
	time_left_1.text = "Ready"
	time_left_2.text = "Ready"
	time_left_3.text = "Ready"
	time_left_4.text = "Ready"
	
func _init_ability(bar, timer, cooldown):
	
	bar.max_value = cooldown
	bar.value = cooldown
	timer.wait_time = cooldown
	timer.one_shot = true

func _process(delta):
	if !ability_1_ready:
		_update_cooldown(timer1, ability_1_bar, time_left_1)
	if !ability_2_ready:
		_update_cooldown(timer2, ability_2_bar, time_left_2)
	if !ability_3_ready:
		_update_cooldown(timer3, ability_3_bar, time_left_3)
	if !ability_4_ready:
		_update_cooldown(timer4, ability_4_bar, time_left_4)

	if Input.is_action_just_pressed("ability1") and ability_1_ready:
		use_ability_1()
	if Input.is_action_just_pressed("ability2") and ability_2_ready:
		use_ability_2()
	if Input.is_action_just_pressed("ability3") and ability_3_ready:
		use_ability_3()
	if Input.is_action_just_pressed("ability4") and ability_4_ready:
		use_ability_4()

func _update_cooldown(timer: Timer, bar: ProgressBar, label: Label):
	var time_left = timer.time_left
	bar.value = time_left
	label.text = str(round(time_left * 10) / 10.0) + "s"

func use_ability_1():
	ability_1_ready = false
	timer1.start()
	ability_1_used.emit()

func use_ability_2():
	ability_2_ready = false
	timer2.start()
	ability_2_used.emit()

func use_ability_3():
	ability_3_ready = false
	timer3.start()
	ability_3_used.emit()

func use_ability_4():
	ability_4_ready = false
	timer4.start()
	ability_4_used.emit()

func _on_timer_timeout():
	ability_1_ready = true
	ability_1_bar.value = cooldown_1
	time_left_1.text = "Ready"

func _on_timer_2_timeout():
	ability_2_ready = true
	ability_2_bar.value = cooldown_2
	time_left_2.text = "Ready"

func _on_timer_3_timeout():
	ability_3_ready = true
	ability_3_bar.value = cooldown_3
	time_left_3.text = "Ready"

func _on_timer_4_timeout():
	ability_4_ready = true
	ability_4_bar.value = cooldown_4
	time_left_4.text = "Ready"
