extends AudioStreamPlayer2D




const HITSOUND = preload("res://sounds/hitsound.mp3")
const CLIACK = preload("res://sounds/cliack.mp3")
const PUNCH_REAL = preload("res://sounds/punch real.mp3")
const SURVIVOR___EYE_OF_THE_TIGER__INSTRUMENTAL_ = preload("res://sounds/Survivor - Eye of the Tiger [Instrumental].mp3")
const FIORA_PASSIVE_REAL = preload("res://sounds/fiora passive real.mp3")
const STARTDASH = preload("res://sounds/startdash.mp3")
const INVULN = preload("res://sounds/invuln.mp3")
const ACTUALDASH = preload("res://sounds/actualdash.mp3")

func _play_music(music: AudioStream, volume = -20.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(SURVIVOR___EYE_OF_THE_TIGER__INSTRUMENTAL_)
	
func play_FX(sound, volume = -3.0, pitch: float = 1.0):
	var fx_player = AudioStreamPlayer.new()
	match sound:
		"fiora":
			fx_player.stream = FIORA_PASSIVE_REAL
			volume -= 3.0
		"hit":
			fx_player.stream = HITSOUND
			volume -= 3.0
		"click":
			fx_player.stream = CLIACK
		"punch":
			fx_player.stream = PUNCH_REAL
			volume -= 10.0
		"player_punch":
			fx_player.stream = PUNCH_REAL
			volume -= 10.0
			pitch = 1.5
		"start_dash":
			fx_player.stream = STARTDASH
		"dash":
			fx_player.stream = ACTUALDASH
		"invuln":
			fx_player.stream = INVULN
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	fx_player.pitch_scale
	add_child(fx_player)
	fx_player.play()
