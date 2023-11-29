extends Area2D

@export_category("Hiding Spot")
@export var hiding_spot_type : String = "Bed"
@onready var canvas_layer = get_parent().get_parent().get_node("CanvasLayer")

var interactible := false


func _input(_event):
	if interactible and Input.is_action_pressed("interact") and !PlayerState.transition_state:
		match (hiding_spot_type):
			"Bed":
				if PlayerState.movement_state == PlayerState.MovementState.CROUCHING:
					print("Hiding Under Bed")
		

func _on_body_entered(body):
	if body.name == "PlayerCharacter":
		canvas_layer.get_node("HBoxContainer/CameraLabel").set_text(hiding_spot_type)
		interactible = true

func _on_body_exited(body):
	if body.name == "PlayerCharacter":
		canvas_layer.get_node("HBoxContainer/CameraLabel").set_text("")
		interactible = false
	
