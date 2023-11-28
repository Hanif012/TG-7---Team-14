extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}

var movement_state := MovementState.IDLE
var position_in_room := 640.0
var current_room := 0
