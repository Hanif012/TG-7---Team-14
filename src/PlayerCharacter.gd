extends CharacterBody2D

signal player_moves

const SPEED = 300.0
const TIRED_TRESHOLD = 200
const STAMINA_CAP = 400
const STAMINA_DRAIN = 4
const STAMINA_REGEN_IDLE = 8
const STAMINA_REGEN_WALKING = 4
const STAMINA_REGEN_CROUCHING = 1
const STAMINA_REGEN_TIRED = 2

var stamina = 600
@export var max_stamina = 600

var state = 0

# Debug
var debug_output
@onready var debug_label = $DebugLabel
@onready var sprite = $Sprite2D

func  _ready():
	position.x = PlayerState.position_in_room
	stamina = max_stamina

func _physics_process(_delta):
	# Handle Tiredness
	if PlayerState.tired_flag:
		if stamina > TIRED_TRESHOLD:
			sprite.modulate = (Color(1, 1, 1, 1))
			PlayerState.tired_flag = false
		else:
			sprite.modulate = (Color(1, 1, 1, 0.5))
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
		if Input.is_action_pressed("ui_down"):
			PlayerState.movement_state = PlayerState.MovementState.CROUCHING
		else:
			PlayerState.movement_state = PlayerState.MovementState.IDLE
		
		
	
func _stamina_handler() -> void:
	match (PlayerState.movement_state):
		PlayerState.MovementState.IDLE:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_IDLE)
		PlayerState.MovementState.WALKING:
			if stamina < STAMINA_CAP:
				stamina = min(STAMINA_CAP, stamina + STAMINA_REGEN_WALKING)
		PlayerState.MovementState.SPRINTING:
			stamina = max(0, stamina - STAMINA_DRAIN)
			PlayerState.tired_flag = !stamina
		PlayerState.MovementState.CROUCHING:
			if stamina < STAMINA_CAP:
				stamina = min(STAMINA_CAP, stamina + STAMINA_REGEN_CROUCHING)
		PlayerState.MovementState.TIRED:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_TIRED)
