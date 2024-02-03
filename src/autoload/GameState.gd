extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}
enum Item {STIM, BANDAGE, MEDKIT, KEY, NOTHING = -1}
enum Room {ATTIC, BATHROOM, BEDROOM, ENDING, GARAGE, HALLWAY, KITCHEN, LIVINGROOM}

const NUM_OF_KEYS = 5
const NUM_OF_STIM = 2
const NUM_OF_BANDAGE = 1
const NUM_OF_MEDKIT = 2

var transition_state := false
var hiding_state := false
var movement_state := MovementState.IDLE
var tired_state := false

var position_in_room := -360.0
var current_room := Room.BEDROOM :
	set(value):
		current_room = value
		check_if_meet_up()
var enemy_location := Room.ATTIC :
	set(value):
		enemy_location = value
		check_if_meet_up()

const DEFAULT_MONSTER_TIMER := 5.0
var remaining_time := DEFAULT_MONSTER_TIMER

const MAX_STAMINA := 600
var stamina := MAX_STAMINA

const MAX_HP := 3
var hp := 3 :
	set(value):
		hp = min(MAX_HP, value)

signal search
signal found_a_key
signal found_an_item(item_type: Item, slot: int)
signal enemy_meet_up()

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
	Item.NOTHING,
	Item.NOTHING]
var inventory : Array[Item] = [Item.NOTHING, Item.NOTHING, Item.NOTHING]

var keys := 0:
	set(value):
		keys = value
		found_a_key.emit()

func _ready():
	stamina = MAX_STAMINA
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
	match (inventory[index]):
		Item.STIM: stamina = 600
		Item.BANDAGE: hp += 1
		Item.MEDKIT: hp = MAX_HP
	inventory[index] = Item.NOTHING

func check_if_meet_up() -> void:
	if current_room == enemy_location:
		enemy_meet_up.emit()
