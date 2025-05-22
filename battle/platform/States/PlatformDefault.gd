extends State
class_name PlatformDefault

var white = "#616161"

func Enter(length):
	await get_tree().process_frame
	get_parent().get_parent().change_color(white)
	
func Update(delta : float):
	pass
	
