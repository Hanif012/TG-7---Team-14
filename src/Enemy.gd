extends CharacterBody2D

signal player_moves

const SPEED = 450.0

@onready var metal_pipe = $MetalPipeSoundQueue
@onready var player_character = get_parent().get_node("PlayerCharacter")

func _physics_process(_delta):
	if player_character.position.x > position.x:
		velocity.x = 1 * SPEED
	elif player_character.position.x < position.x:
		velocity.x = -1 * SPEED
	else:
		velocity.x = 0
	
	move_and_slide()

	for i in get_slide_collision_count():
		print("COLLIDE")
		self.queue_free()
