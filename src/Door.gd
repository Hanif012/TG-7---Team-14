extends Area2D

@export_category("Door Destination")
@export var target_room : String
@export var coords : int
@export var room_name : String
@onready var canvas_layer = get_parent().get_parent().get_node("CanvasLayer")

var interactible := false


func _input(_event):
	if interactible and Input.is_action_pressed("interact") and !PlayerState.transition_state:
		print("Interacted with door ", name)
		PlayerState.position_in_room = coords
		SceneTransition.change_screen(target_room)

func _on_body_entered(body):
	if body.name == "PlayerCharacter":
		canvas_layer.get_node("HBoxContainer/CameraLabel").set_text(room_name)
		interactible = true

func _on_body_exited(body):
	if body.name == "PlayerCharacter":
		canvas_layer.get_node("HBoxContainer/CameraLabel").set_text("")
		interactible = false
	
