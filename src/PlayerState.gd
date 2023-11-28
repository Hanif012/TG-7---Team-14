extends Node

enum MovementState {IDLE, WALKING, SPRINTING, CROUCHING, TIRED}

var movement_state = MovementState.IDLE
