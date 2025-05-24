extends AudioStreamPlayer2D

var level_music


const HITSOUND = preload("res://sounds/hitsound.mp3")
const FIORAPASSIVE = preload("res://sounds/fiorapassive.mp3")
const CLIACK = preload("res://sounds/cliack.mp3")
func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(level_music)
	
func play_FX(sound, volume = 0.0):
	var fx_player = AudioStreamPlayer.new()
	match sound:
		"fiora":
			fx_player.stream = FIORAPASSIVE
		"hit":
			fx_player.stream = HITSOUND
		"click":
			fx_player.stream = CLIACK
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	add_child(fx_player)
	fx_player.play()
