extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}

var transition_state := false
var movement_state := MovementState.IDLE
var tired_flag := false

var position_in_room := 0.0
var current_room := 0

var stamina := 600
var max_stamina := 600

func _ready():
	stamina = max_stamina
