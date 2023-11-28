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

var state = 0

# Debug
var debug_output
@onready var debug_label = $DebugLabel
@onready var sprite = $Sprite2D

func  _ready():
	position.x = PlayerState.position_in_room

func _physics_process(_delta):
	# Handle Tiredness
	if PlayerState.tired_flag:
		if PlayerState.stamina > TIRED_TRESHOLD:
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
	debug_output = str("Stamina: ",PlayerState.stamina, "/ ", PlayerState.max_stamina, "\nVelocity:", velocity.x, "\nPlayerstate:", PlayerState.movement_state)
	
	debug_label.set_text(debug_output)
	
	move_and_slide()

func _movement_handler() -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if Input.is_action_pressed("ui_down"):
			velocity.x = direction * SPEED / 2
			PlayerState.movement_state = PlayerState.MovementState.CROUCHING
		elif Input.is_action_pressed("sprint"):
			if PlayerState.stamina > 0:
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
			PlayerState.stamina = min(PlayerState.max_stamina, PlayerState.stamina + STAMINA_REGEN_IDLE)
		PlayerState.MovementState.WALKING:
			if PlayerState.stamina < STAMINA_CAP:
				PlayerState.stamina = min(PlayerState.STAMINA_CAP, PlayerState.stamina + STAMINA_REGEN_WALKING)
		PlayerState.MovementState.SPRINTING:
			PlayerState.stamina = max(0, PlayerState.stamina - STAMINA_DRAIN)
			PlayerState.tired_flag = !PlayerState.stamina
		PlayerState.MovementState.CROUCHING:
			if PlayerState.stamina < STAMINA_CAP:
				PlayerState.stamina = min(STAMINA_CAP, PlayerState.stamina + STAMINA_REGEN_CROUCHING)
		PlayerState.MovementState.TIRED:
			PlayerState.stamina = min(PlayerState.max_stamina, PlayerState.stamina + STAMINA_REGEN_TIRED)
