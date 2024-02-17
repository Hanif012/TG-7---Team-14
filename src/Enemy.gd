extends CharacterBody2D

signal player_moves

var in_attack_animation = false
@onready var metal_pipe = $MetalPipeSoundQueue
@onready var player_character = get_parent().get_node("Player")

func _physics_process(_delta):
	if not in_attack_animation:
		if abs(player_character.position.x - position.x) < GameState.WIND_UP_DISTANCE:
			commence_attack()
		else:
			if player_character.position.x > position.x:
				velocity.x = 1 * GameState.ENEMY_SPEED
				$Sprite2D.flip_h = false
			elif player_character.position.x < position.x:
				velocity.x = -1 * GameState.ENEMY_SPEED
				$Sprite2D.flip_h = true
			else:
				velocity.x = 0
			move_and_slide()
		
		
func commence_attack():
	in_attack_animation = true 
	
	$StrikeTimer.start()
	await $StrikeTimer.timeout   # Attacking Charging time
	
	$Sprite2D.flip_v = true
	var distance = player_character.position.x - position.x
	if distance < GameState.STRIKE_DISTANCE and distance >= 0 and !$Sprite2D.flip_h:
		GameState.hp -= 1
	elif distance > -GameState.STRIKE_DISTANCE and distance <= 0 and $Sprite2D.flip_h:
		GameState.hp -= 1
	
	print(GameState.hp, "/", GameState.MAX_HP)
	
	$CooldownTimer.start()
	await $CooldownTimer.timeout   # Recovery time

	$Sprite2D.flip_v = false
	in_attack_animation = false
