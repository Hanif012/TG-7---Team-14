extends CharacterBody2D


const SPEED = 200.0
const TIRED_TRESHOLD = 200
const WALK_STAMINA_CAP = 400
const STAMINA_DRAIN = 4
const STAMINA_REGEN_IDLE = 8
const STAMINA_REGEN_WALKING = 4
const STAMINA_REGEN_CROUCHING = 1
const STAMINA_REGEN_TIRED = 2

var stamina = 600
@export var max_stamina = 600

var state = 0
var tired_flag = false

#debug
var debug_output
@onready var debug_label = $DebugLabel

func  _ready():
	position.x = PlayerState.position_in_room
	stamina = max_stamina
func _process(delta):
	# Handle Tiredness
	if tired_flag:
		if stamina > TIRED_TRESHOLD:
			tired_flag = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED / 3)
			PlayerState.movement_state = PlayerState.MovementState.TIRED
	else:
		_movement_handler()
	_stamina_handler()
	
	# Debug
	debug_output = str("Stamina: ",stamina, "/ ", max_stamina, "\nVelocity:", velocity.x, "\nPlayerstate:", PlayerState.movement_state)
	
	debug_label.set_text(debug_output)
	

	move_and_slide()

func _movement_handler() -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if Input.is_action_pressed("ui_down"):
			velocity.x = direction * SPEED / 2
			PlayerState.movement_state = PlayerState.MovementState.CROUCHING
		elif Input.is_action_pressed("sprint"):
			if stamina > 0:
				velocity.x = direction * SPEED * 2
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			PlayerState.movement_state = PlayerState.MovementState.SPRINTING
		else:
			velocity.x = direction * SPEED
			PlayerState.movement_state = PlayerState.MovementState.WALKING
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		PlayerState.movement_state = PlayerState.MovementState.IDLE
	
func _stamina_handler() -> void:
	match (PlayerState.movement_state):
		PlayerState.MovementState.IDLE:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_IDLE)
		PlayerState.MovementState.WALKING:
			if stamina < WALK_STAMINA_CAP:
				stamina = min(WALK_STAMINA_CAP, stamina + STAMINA_REGEN_WALKING)
		PlayerState.MovementState.SPRINTING:
			stamina = max(0, stamina - STAMINA_DRAIN)
			tired_flag = !stamina
		PlayerState.MovementState.CROUCHING:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_CROUCHING)
		PlayerState.MovementState.TIRED:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_TIRED)
