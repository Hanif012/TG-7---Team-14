extends CharacterBody2D

signal player_moves

var saw_player_when_entering_room := true
var in_attack_animation := false
@onready var metal_pipe = $MetalPipeSoundQueue
@onready var player_character = get_parent().get_node("Player")
@onready var room = get_parent().get_parent()

func _ready() -> void:
	if GameState.hiding_state:
		saw_player_when_entering_room = false
		GameState.enemy_state = GameState.EnemyState.LOSTTRACK
		room.enemy_handler.run_enemy_handler()

func _physics_process(_delta):
	if !in_attack_animation :
		if !saw_player_when_entering_room:
			return
		elif abs(player_character.position.x - position.x) < GameState.WIND_UP_DISTANCE:
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
	if distance < GameState.STRIKE_DISTANCE and distance >= -GameState.STRIKE_DISTANCE/5 and !$Sprite2D.flip_h:
		GameState.hp -= 1
		GameState.adrenaline_rush()
	elif distance > -GameState.STRIKE_DISTANCE and distance <= GameState.STRIKE_DISTANCE/5 and $Sprite2D.flip_h:
		GameState.hp -= 1
		GameState.adrenaline_rush()
	
	print(GameState.hp, "/", GameState.MAX_HP)
	
	$CooldownTimer.start()
	await $CooldownTimer.timeout   # Recovery time

	$Sprite2D.flip_v = false
	in_attack_animation = false
