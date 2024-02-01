extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}
enum Item {STIM, BANDAGE, MEDKIT, KEY, NOTHING = -1}

var transition_state := false
var hiding_state := false
var movement_state := MovementState.IDLE
var tired_state := false

var position_in_room := -360.0
var current_room := 0

const MAX_STAMINA := 600
var stamina := 600

signal search
signal found_a_key
signal found_an_item(item_type: Item, slot: int)

var item_index = {
	1: Item.STIM,
	2: Item.BANDAGE,
	3: Item.MEDKIT,
	4: Item.KEY,
	5: Item.STIM
}

var inventory : Array[Item] = [Item.NOTHING, Item.NOTHING, Item.NOTHING]

var keys := 0:
	set(value):
		keys = value
		found_a_key.emit()
		
func _ready():
	stamina = MAX_STAMINA
