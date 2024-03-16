extends Area2D
class_name Interactible

enum InteractibleType {DOOR, STEALTH, STORAGE}
enum HidingSpotType {BED, WARDROBE}

@export var interactible_type : InteractibleType
@export var label : String
@export var emit_sound_type : String

@export_category("Door Type")
@export var target_room : String
@export var coords : int

@export_category("Stealth Type")
@export var hiding_spot_type : HidingSpotType

@export_category("Storage Type")
@export var storage_index : int
var item_here : GameState.Item

@onready var ui = get_parent().get_parent().get_node("UI")
@onready var interact = ui.get_node("Control/InteractBG")
@onready var interact_label = interact.get_node("InteractLabel")
@onready var contextual = ui.get_node("Control/ContextualBG")
@onready var contextual_label = contextual.get_node("ContextualLabel")

@onready var enemy_handler = get_parent().get_parent().get_node("EnemyHandler")

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
	if body.name == "Player":
		
		interact_label.set_text(label)
		interact.show()
		is_interactible = true

func _on_body_exited(body) -> void:
	if body.name == "Player":
		interact.hide()
		contextual.hide()
		is_interactible = false
	
func _change_scene() -> void:
	GameState.player_position = coords
	var characters := get_parent().get_parent().get_node("Characters")
	if characters.get_child_count() > 1:
		GameState.enemy_position = characters.get_node("Enemy").position.x
		GameState.enemy_distance = abs(characters.get_node("Player").position.x - GameState.enemy_position)
#		print("Enemy Distance: ", GameState.enemy_distance)
	else:
		if GameState.enemy_state == GameState.EnemyState.CHASING:
			GameState.enemy_state = GameState.EnemyState.LOSTTRACK
		
	if target_room != "Exit":
		GameState.time_left = enemy_handler.get_node("EnemyMovementTimer").time_left
		get_tree().change_scene_to_file("res://src/rooms/" + target_room + ".tscn")
	else:
		if GameState.keys == GameState.NUM_OF_KEYS:
			get_tree().change_scene_to_file("res://src/rooms/Ending.tscn")
		else:
			contextual_label.set_text("The Key is Incomplete")
			contextual.show()
	
func _enter_hiding_spot() -> void:
	GameState.hiding_state = !GameState.hiding_state
	var characters := get_parent().get_parent().get_node("Characters")
	if GameState.hiding_state:
		characters.get_node("Player/Sprite2D").hide()
		contextual_label.set_text("You are hiding...")
		contextual.show()
	else:
		if characters.get_child_count() > 1:
			characters.get_node("Enemy").saw_player_when_entering_room = true
			GameState.enemy_state = GameState.EnemyState.ROAMING
		characters.get_node("Player/Sprite2D").show()
		contextual.hide()

func _pick_up_item() -> void:
	GameState.emit_sound.emit(emit_sound_type)
	if item_here == GameState.Item.KEY:
		GameState.keys += 1
		contextual_label.set_text("Found a Piece of the Key")
		contextual.show()
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
	
		match (item_here):
			GameState.Item.STIM: contextual_label.set_text("Found an Energy Drink")
			GameState.Item.BANDAGE: contextual_label.set_text("Found Bandages")
			GameState.Item.MEDKIT: contextual_label.set_text("Found a Medkit")
		contextual.show()
	else:
		contextual_label.set_text("Nothing Was Found")
		contextual.show()
		
	GameState.item_index[storage_index] = GameState.Item.NOTHING
	item_here = GameState.Item.NOTHING
