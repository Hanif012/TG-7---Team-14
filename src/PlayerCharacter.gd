extends CharacterBody2D


const SPEED = 300.0
const TIRED_TRESHOLD = 50.0
const STAMINA_DRAIN = 1
const STAMINA_REGEN_IDLE = 2
const STAMINA_REGEN_WALKING = 1
const STAMINA_REGEN_CROUCHING = 0.25
const STAMINA_REGEN_TIRED = 0.5

var stamina = 150.0
var max_stamina = 150.0
var state = 0
var tired_flag = false

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

	print(stamina, " | ", velocity.x, " | ", PlayerState.movement_state)

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
			if stamina < 100:
				stamina = min(100, stamina + STAMINA_REGEN_WALKING)
		PlayerState.MovementState.SPRINTING:
			stamina = max(0, stamina - STAMINA_DRAIN)
			tired_flag = !stamina
		PlayerState.MovementState.CROUCHING:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_CROUCHING)
		PlayerState.MovementState.TIRED:
			stamina = min(max_stamina, stamina + STAMINA_REGEN_TIRED)
