extends Area2D

@export_category("Door Destination")
@export var target_room : int
@export var coords : int
@export var room_name : String
@onready var camera_label = get_parent().get_parent().get_node("Camera2D/CameraLabel")

var interactible := false

func _on_body_entered(body):
	if body.name == "PlayerCharacter":
		camera_label.set_text(room_name)
	

func _on_body_exited(body):
	if body.name == "PlayerCharacter":
		camera_label.set_text("")
	
