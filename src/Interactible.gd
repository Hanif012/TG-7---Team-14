extends Area2D

enum InteractibleType {DOOR, STEALTH, STORAGE}
enum HidingSpotType {BED, WARDROBE}
enum ItemContained {KEY, HEAL, STIM}

@export var interactible_type : InteractibleType
@export var label : String

@export_category("Door Type")
@export var target_room : String
@export var coords : int

@export_category("Stealth Type")
@export var hiding_spot_type : HidingSpotType

@export_category("Storage Type")
@export var spot_name : String = "Desk"
@export var item_here : ItemContained


var is_interactible := false


func _input(_event):
	if is_interactible and Input.is_action_pressed("interact") and !GameState.transition_state:
		match (interactible_type):
			InteractibleType.DOOR:
				_change_scene()
			InteractibleType.STEALTH:
				_enter_hiding_spot()
			InteractibleType.STORAGE:
				_pick_up_item()
		

func _on_body_entered(body):
	if body.name == "PlayerCharacter":
		
		UI.get_node("HBoxContainer/InteractLabel").set_text(label)
		is_interactible = true

func _on_body_exited(body):
	if body.name == "PlayerCharacter":
		UI.get_node("HBoxContainer/InteractLabel").set_text("")
		is_interactible = false
	
func _change_scene():
	GameState.position_in_room = coords
	get_tree().change_scene_to_file("res://src/rooms/" + target_room + ".tscn")
	
func _enter_hiding_spot():
	print("Hiding in ", HidingSpotType.keys()[hiding_spot_type])

func _pick_up_item():
	print("Picked up ", ItemContained.keys()[item_here])
