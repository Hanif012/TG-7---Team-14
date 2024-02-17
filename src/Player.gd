extends CharacterBody2D

signal player_moves


const TIRED_TRESHOLD = 200
const STAMINA_CAP = 300
const STAMINA_DRAIN = 4
const STAMINA_REGEN_IDLE = 8
const STAMINA_REGEN_WALKING = 4
const STAMINA_REGEN_CROUCHING = 1
const STAMINA_REGEN_TIRED = 2


var state = 0

@onready var metal_pipe = $MetalPipeSoundQueue

# Debug
var debug_output
@onready var debug_label = $DebugLabel
@onready var sprite = $Sprite2D

# On ready, set position to starting position or door position
func  _ready():
	GameState.search.connect(play_search_sound)
	position.x = GameState.player_position

func play_search_sound():
		metal_pipe.play_sound()

func _physics_process(_delta):
	if GameState.hiding_state: # ignore movement if hiding 
		velocity.x = 0
	elif GameState.tired_state:
		if GameState.stamina > TIRED_TRESHOLD: # If no longer tired, reset tired_state and sprite
			sprite.modulate = (Color(1, 1, 1, 1))
			GameState.tired_state = false
		else:
			sprite.modulate = (Color(1, 1, 1, 0.5)) # Decelerate and handle stamina recovery when tired
			velocity.x = 0
			GameState.movement_state = GameState.MovementState.TIRED
	else:
		_movement_handler()
	_stamina_handler()
	
	# Debug
	debug_output = str("Stamina: ",GameState.stamina, "/ ", GameState.MAX_STAMINA, "\nVelocity:", velocity.x, "\nGameState:", GameState.movement_state, "\nPosition:", position.x)
	debug_label.set_text(debug_output)
	
	move_and_slide()

func _movement_handler() -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if Input.is_action_pressed("crouch"):
			velocity.x = direction * GameState.speed / 2
			GameState.movement_state = GameState.MovementState.CROUCHING
		elif Input.is_action_pressed("sprint"):
			if GameState.stamina > 0:
				velocity.x = direction * GameState.speed * 2
			else:
				velocity.x = 0
			GameState.movement_state = GameState.MovementState.SPRINTING
		else:
			velocity.x = direction * GameState.speed
			GameState.movement_state = GameState.MovementState.WALKING
	else:
		velocity.x = 0
		if Input.is_action_pressed("crouch"):
			GameState.movement_state = GameState.MovementState.CROUCHING
		else:
			GameState.movement_state = GameState.MovementState.IDLE
	
	match GameState.movement_state:
		GameState.MovementState.IDLE, GameState.MovementState.TIRED:
			$AnimationPlayer.play("RESET")
		GameState.MovementState.WALKING:
			$AnimationPlayer.play("walk")
		GameState.MovementState.SPRINTING:
			$AnimationPlayer.play("run")
	
	if velocity.x != 0:
		if velocity.x > 0:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true

func _stamina_handler() -> void:
	if GameState.hiding_state:
		if GameState.stamina < STAMINA_CAP:
			GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_CROUCHING)
	else: 
		match (GameState.movement_state):
			GameState.MovementState.IDLE:
				GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_IDLE)
			GameState.MovementState.WALKING:
					GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_WALKING)
			GameState.MovementState.SPRINTING:
				GameState.stamina = max(0, GameState.stamina - STAMINA_DRAIN)
				if GameState.stamina == 0:
					GameState.tired_state = true
					sprite.modulate = (Color(1, 1, 1, 0.5))
			GameState.MovementState.CROUCHING:
				if GameState.stamina < STAMINA_CAP:
					GameState.stamina = min(STAMINA_CAP, GameState.stamina + STAMINA_REGEN_CROUCHING)
			GameState.MovementState.TIRED:
				GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_TIRED)
