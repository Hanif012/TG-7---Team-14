extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}

var movement_state := MovementState.IDLE
var tired_flag := false

var position_in_room := 0.0
var current_room := 0
