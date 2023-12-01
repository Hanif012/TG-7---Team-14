extends Area2D

enum InteractibleType {DOOR, STEALTH, STORAGE}
enum HidingSpotType {BED, WARDROBE}

@export var interactible_type : InteractibleType
@export var label : String

@export_category("Door Type")
@export var target_room : String
@export var coords : int

@export_category("Stealth Type")
@export var hiding_spot_type : HidingSpotType

@export_category("Storage Type")
@export var spot_name : String = "Desk"
@export var item_here : GameState.Item


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
		

func _on_body_entered(body) -> void:
	if body.name == "PlayerCharacter":
		
		UI.get_node("HBoxContainer/InteractLabel").set_text(label)
		is_interactible = true

func _on_body_exited(body) -> void:
	if body.name == "PlayerCharacter":
		UI.get_node("HBoxContainer/InteractLabel").set_text("")
		is_interactible = false
	
func _change_scene() -> void:
	GameState.position_in_room = coords
	get_tree().change_scene_to_file("res://src/rooms/" + target_room + ".tscn")
	
func _enter_hiding_spot() -> void:
	GameState.hiding_state = !GameState.hiding_state
	if GameState.hiding_state:
		print("Hiding in ", HidingSpotType.keys()[hiding_spot_type])
	else:
		print("Came out from ", HidingSpotType.keys()[hiding_spot_type])

func _pick_up_item() -> void:
	if item_here == GameState.Item.KEY:
		GameState.key_couter += 1
	elif item_here != -1:
		if GameState.inventory[0] != -1:
			GameState.inventory[0] = item_here
		elif GameState.inventory[1] != -1:
			GameState.inventory[1] = item_here
		elif GameState.inventory[2] != -1:
			GameState.inventory[2] = item_here
		else:
			print("Inventory Full")
	
	item_here = -1
	print("[" , GameState.inventory[0], ", ", GameState.inventory[1], ", ", GameState.inventory[2] ,"] Key Found: ", GameState.key_couter)
