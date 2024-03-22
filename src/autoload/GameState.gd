extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}
enum Item {STIM, BANDAGE, MEDKIT, KEY, NOTHING = -1}
enum Room {ATTIC, BATHROOM, BEDROOM, GARAGE, HALLWAY, KITCHEN, LIVINGROOM}
enum EnemyState {ROAMING, CHASING, LOSTTRACK, FINAL}

const NUM_OF_KEYS = 5
const NUM_OF_STIM = 2
const NUM_OF_BANDAGE = 1
const NUM_OF_MEDKIT = 2

var game_start := true
var transition_state := false
var hiding_state := false
var movement_state := MovementState.IDLE
var tired_state := false

var player_position := -360.0
var enemy_position := 0.0
var player_location := Room.BEDROOM:
	set(value):
		last_player_location = player_location
		player_location = value
var last_player_location := Room.BEDROOM
var enemy_location := Room.ATTIC
var enemy_distance := 0

const ENEMY_SPEED = 375.0

const DEFAULT_MONSTER_TIMER := 3.0
var time_left := DEFAULT_MONSTER_TIMER

var enemy_state := EnemyState.ROAMING

const MAX_STAMINA := 600
var stamina := MAX_STAMINA

const MAX_HP := 3
var hp := 3 :
	set(value):
		hp = clamp(value, 0, MAX_HP)
		hp_changed.emit()
		if hp == 0:
			get_tree().change_scene_to_file("res://src/menu/GameOverMenu.tscn")

const DEFAULT_SPEED := 300.0
var speed := DEFAULT_SPEED

const WIND_UP_DISTANCE = 200
const STRIKE_DISTANCE = WIND_UP_DISTANCE*1.5

signal emit_sound(str: String)
signal found_a_key
signal hp_changed
signal found_an_item(item_type: Item, slot: int)
signal enemy_meet_up(spawn_position: int)

var item_index : Array[Item] = [
	Item.STIM,
	Item.BANDAGE,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING,
	Item.NOTHING]
var inventory : Array[Item] = [Item.NOTHING, Item.NOTHING, Item.NOTHING]

var keys := 0:
	set(value):
		keys = value
		found_a_key.emit()


func restart_game():
	game_start = true
	transition_state = false
	hiding_state = false
	movement_state = MovementState.IDLE
	tired_state = false
	
	hp = MAX_HP
	stamina = MAX_STAMINA
	
	player_position = -360.0
	enemy_position = 0.0
	player_location = Room.BEDROOM
	last_player_location = Room.BEDROOM
	enemy_location = Room.ATTIC
	enemy_distance = 0
	
	time_left = DEFAULT_MONSTER_TIMER

	enemy_state = EnemyState.ROAMING
	speed = DEFAULT_SPEED
	
	item_index = [
		Item.STIM, Item.BANDAGE, Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, 
		Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, 
		Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING, Item.NOTHING
	]
	inventory = [Item.NOTHING, Item.NOTHING, Item.NOTHING]
	keys = 0
	distribute_items()

func distribute_items() -> void :
	var possible_locations = range(2, len(item_index))
	possible_locations = randomize_location(NUM_OF_KEYS, Item.KEY, possible_locations)
	possible_locations = randomize_location(NUM_OF_STIM, Item.STIM, possible_locations)
	possible_locations = randomize_location(NUM_OF_BANDAGE, Item.BANDAGE, possible_locations)
	possible_locations = randomize_location(NUM_OF_MEDKIT, Item.MEDKIT, possible_locations)
 
func randomize_location(instances: int, item_type: Item, locations: Array) -> Array:
	var idx
	for i in range(instances):
		idx = randi() % len(locations)
		item_index[locations[idx]] = item_type
		locations.remove_at(idx)
		
	return locations

func item_consumption(index: int):
	var ui = get_node("/root/Room/UI")
	match (inventory[index]):
		Item.STIM: 
			stamina = 600
			adrenaline_rush()
			ui.contextual_label.set_text("Used Energy Drink")
		Item.BANDAGE: 
			hp += 1
			ui.contextual_label.set_text("Used Bandage")
		Item.MEDKIT: 
			hp = MAX_HP
			ui.contextual_label.set_text("Used Medkit")
	inventory[index] = Item.NOTHING

func check_if_meet_up() -> void:
#	print_tree()
#	return
	var characters = get_node("/root/Room/Characters")
#	print(characters)
	if player_location == enemy_location:
		if enemy_state == EnemyState.ROAMING:
			enemy_meet_up.emit()
		else:
			enemy_meet_up.emit(enemy_position)
		enemy_state = EnemyState.CHASING
	else:
		if characters.get_child_count() > 1: 
			characters.get_node("Enemy").queue_free()

func adrenaline_rush() -> void:
	speed = DEFAULT_SPEED * 1.5
	await get_tree().create_timer(5).timeout
	speed = DEFAULT_SPEED
