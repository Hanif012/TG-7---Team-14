extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}
enum Item {KEY, STIM, BANDAGE, MEDKIT}

var transition_state := false
var hiding_state := false
var movement_state := MovementState.IDLE
var tired_state := false

var position_in_room := -360.0
var current_room := 0

const MAX_STAMINA := 600
var stamina := 600

var inventory = [-1, -1, -1]
var key_couter := 0
func _ready():
	stamina = MAX_STAMINA
