extends CharacterBody2D


const SPEED = 300.0
const TIRED_TRESHOLD = 10.0
const STAMINA_DRAIN = 2
const STAMINA_REGEN_STILL = 1
const STAMINA_REGEN_MOVING = 0.2

var stamina = 200.0
var tired_flag = false

func _process(delta):
	# Movement controller
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Sprint Detection
	if Input.is_action_pressed("sprint"):
		if stamina > 0:
			stamina = max(0, stamina-1)
			velocity.x *= 2
			# Apply tiredFlag if drops to 0 stamina
			if !stamina:
				tiredFlag = true
	# Stamina Regeneration
	else: 
		# Different stamina regeneration speed based on if you're standing still or not
		if !velocity.x:
			stamina = min(240, stamina+0.5)
		else:
			stamina = min(240, stamina+0.1)
		
		# Remove TiredFlag after a certain stamina treshold
		if stamina > TIRED_TRESHOLD and tiredFlag:
			tiredFlag = false
	
	# Stop movement if tiredFlag is true
	if tiredFlag:
		velocity.x = 0
	
	print(stamina, " | ", velocity.x)

	move_and_slide()
