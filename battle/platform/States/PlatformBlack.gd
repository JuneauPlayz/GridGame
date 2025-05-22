extends State
class_name PlatformBlack

var black = "#121111"

func Enter(length):
	await get_tree().process_frame
	get_parent().get_parent().change_color(black)
	
func Update(delta : float):
	pass
	
