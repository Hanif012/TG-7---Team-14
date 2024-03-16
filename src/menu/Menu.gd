extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
#	CanvasItemMaterial.LIGHT_MODE_UNSHADED
	pass


func _on_play_pressed():
	get_tree().change_scene_to_file("res://src/rooms/Bedroom.tscn")


func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	#to-do: add Animation Here
	get_tree().quit()


