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
	position.x = GameState.position_in_room

func _physics_process(_delta):
	if GameState.hiding_state:
		velocity.x = 0
	elif GameState.tired_state:
		if GameState.stamina > TIRED_TRESHOLD:
			sprite.modulate = (Color(1, 1, 1, 1))
			GameState.tired_state = false
		else:
			sprite.modulate = (Color(1, 1, 1, 0.5))
			velocity.x = move_toward(velocity.x, 0, SPEED / 3)
			GameState.movement_state = GameState.MovementState.TIRED
	else:
		_movement_handler()
	_stamina_handler()
	
	# Debug
	debug_output = str("Stamina: ",GameState.stamina, "/ ", GameState.MAX_STAMINA, "\nVelocity:", velocity.x, "\nGameState:", GameState.movement_state)
	
	debug_label.set_text(debug_output)
	
	move_and_slide()

func _movement_handler() -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if Input.is_action_pressed("crouch"):
			velocity.x = direction * SPEED / 2
			GameState.movement_state = GameState.MovementState.CROUCHING
		elif Input.is_action_pressed("sprint"):
			if GameState.stamina > 0:
				velocity.x = direction * SPEED * 2
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			GameState.movement_state = GameState.MovementState.SPRINTING
		else:
			velocity.x = direction * SPEED
			GameState.movement_state = GameState.MovementState.WALKING
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_pressed("crouch"):
			GameState.movement_state = GameState.MovementState.CROUCHING
		else:
			GameState.movement_state = GameState.MovementState.IDLE
	
func _stamina_handler() -> void:
	if GameState.hiding_state:
		if GameState.stamina < STAMINA_CAP:
			GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_CROUCHING)
	else: 
		match (GameState.movement_state):
			GameState.MovementState.IDLE:
				GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_IDLE)
			GameState.MovementState.WALKING:
				if GameState.stamina < STAMINA_CAP:
					GameState.stamina = min(STAMINA_CAP, GameState.stamina + STAMINA_REGEN_WALKING)
			GameState.MovementState.SPRINTING:
				GameState.stamina = max(0, GameState.stamina - STAMINA_DRAIN)
				GameState.tired_state = !GameState.stamina
			GameState.MovementState.CROUCHING:
				if GameState.stamina < STAMINA_CAP:
					GameState.stamina = min(STAMINA_CAP, GameState.stamina + STAMINA_REGEN_CROUCHING)
			GameState.MovementState.TIRED:
				GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_TIRED)
