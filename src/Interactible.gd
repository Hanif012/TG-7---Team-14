extends Area2D
class_name Interactible

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
@export var storage_index : int
var item_here : GameState.Item

@onready var ui = get_parent().get_parent().get_node("UI")
@onready var interact_label = ui.get_node("Control/InteractLabel")
@onready var contextual = ui.get_node("Control/ContextualBG")
@onready var contextual_label = contextual.get_node("ContextualLabel")


var is_interactible := false

func _ready():
	if interactible_type == InteractibleType.STORAGE:
		item_here = GameState.item_index[storage_index]

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
		
		interact_label.set_text(label)
		is_interactible = true

func _on_body_exited(body) -> void:
	if body.name == "PlayerCharacter":
		interact_label.set_text("")
		contextual.hide()
		is_interactible = false
	
func _change_scene() -> void:
	GameState.position_in_room = coords
	if target_room != "Exit":
		get_tree().change_scene_to_file("res://src/rooms/" + target_room + ".tscn")
	else:
		if GameState.keys == 3:
			get_tree().change_scene_to_file("res://src/rooms/Ending.tscn")
		else:
			contextual_label.set_text("Not Enough Keys to Escape")
			contextual.show()
	
func _enter_hiding_spot() -> void:
	GameState.hiding_state = !GameState.hiding_state
	if GameState.hiding_state:
		print("Hiding in ", HidingSpotType.keys()[hiding_spot_type])
	else:
		print("Came out from ", HidingSpotType.keys()[hiding_spot_type])

func _pick_up_item() -> void:
	GameState.search.emit()
	if item_here == GameState.Item.KEY:
		GameState.keys += 1
	elif item_here != GameState.Item.NOTHING:
		if GameState.inventory[0] == GameState.Item.NOTHING:
			GameState.inventory[0] = item_here
			GameState.found_an_item.emit(int(item_here), 0)
		elif GameState.inventory[1] == GameState.Item.NOTHING:
			GameState.inventory[1] = item_here
			GameState.found_an_item.emit(int(item_here), 1)
		elif GameState.inventory[2] == GameState.Item.NOTHING:
			GameState.inventory[2] = item_here
			GameState.found_an_item.emit(int(item_here), 2)
		else:
			contextual_label.set_text("Inventory is Full")
			contextual.show()
			return
	
	GameState.item_index[storage_index] = -1
	item_here = GameState.Item.NOTHING
