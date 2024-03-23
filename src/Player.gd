extends CharacterBody2D

signal player_moves

@onready var walk_audio_player = $WalkAudioPlayer

const TIRED_TRESHOLD = 200
const STAMINA_CAP = 300
const STAMINA_DRAIN = 4
const STAMINA_REGEN_IDLE = 8
const STAMINA_REGEN_WALKING = 4
const STAMINA_REGEN_CROUCHING = 1
const STAMINA_REGEN_TIRED = 2

const DEFAULT_FOOTSTEP_PITCH = 0.5
var footstep_pitch = 0.5

var state = 0

var audio_track : int = 0:
	set(value):
		if (value != audio_track):
			_play_audio_track(value)
		audio_track = value

signal update_stamina()

@onready var sprite = $Sprite2D
@onready var ui = get_parent().get_parent().get_node("UI")

# On ready, set position to starting position or door position
func  _ready():
	position.x = GameState.player_position
	update_stamina.connect(ui.update_stamina_bar)


func _physics_process(_delta):
	if GameState.hiding_state: # ignore movement if hiding 
		velocity.x = 0
	elif GameState.tired_state:
		if GameState.stamina > TIRED_TRESHOLD: # If no longer tired, reset tired_state and sprite
#			sprite.modulate = (Color(1, 1, 1, 1))
			GameState.tired_state = false
			ui.stamina_bar.self_modulate = "ffffff"
		else:
#			sprite.modulate = (Color(1, 1, 1, 0.5)) # Decelerate and handle stamina recovery when tired
			velocity.x = 0
			GameState.movement_state = GameState.MovementState.TIRED
		
	else:
		_movement_handler()
	_stamina_handler()
	
	update_stamina.emit()
	
	_play_anim()
	move_and_slide()

func _movement_handler() -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if Input.is_action_pressed("sprint"):
			if GameState.stamina > 0:
				GameState.movement_state = GameState.MovementState.SPRINTING
				velocity.x = direction * GameState.speed * 2
			else:
				GameState.movement_state = GameState.MovementState.TIRED
				velocity.x = 0
		else:
			velocity.x = direction * GameState.speed
			GameState.movement_state = GameState.MovementState.WALKING
	else:
		velocity.x = 0
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
					GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_WALKING)
			GameState.MovementState.SPRINTING:
				GameState.stamina = max(0, GameState.stamina - STAMINA_DRAIN)
				if GameState.stamina == 0:
					GameState.tired_state = true
					ui.stamina_bar.self_modulate = "ff0000"
#					sprite.modulate = (Color(1, 1, 1, 0.5))
			GameState.MovementState.TIRED:
				GameState.stamina = min(GameState.MAX_STAMINA, GameState.stamina + STAMINA_REGEN_TIRED)

func _play_anim() -> void:
	match GameState.movement_state:
		GameState.MovementState.IDLE:
			$AnimationPlayer.play("RESET")
			$AnimationPlayer.speed_scale = 1
			audio_track = 0
		GameState.MovementState.TIRED:
			if !$Sprite2D.flip_h:
				$AnimationPlayer.play("tired_right")
			else:
				$AnimationPlayer.play("tired_left")
			$AnimationPlayer.speed_scale = 0.5
			audio_track = 0
		GameState.MovementState.WALKING:
			if velocity.x > 0:
				$AnimationPlayer.play("walk_right")
			else:
				$AnimationPlayer.play("walk_left")
			$AnimationPlayer.speed_scale = 0.75
			audio_track = 1
		GameState.MovementState.SPRINTING:
			if velocity.x > 0:
				$AnimationPlayer.play("run_right")
			else:
				$AnimationPlayer.play("run_left")
			$AnimationPlayer.speed_scale = 1.25
			audio_track = 2
	
	if GameState.rush: $AnimationPlayer.speed_scale *= 1.5
		
	if velocity.x != 0:
		if velocity.x > 0:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true

func _play_audio_track(value: int):
	var audio_rng = randi_range(0, 2) 
	match value:
		1: 
			walk_audio_player.stream = GameState.FOOTSTEP_WOOD[audio_rng]
			walk_audio_player.pitch_scale = DEFAULT_FOOTSTEP_PITCH

		2: 
			walk_audio_player.stream = GameState.FOOTSTEP_WOOD[audio_rng]
			walk_audio_player.pitch_scale = DEFAULT_FOOTSTEP_PITCH * 1.5

	if value == 0:
		walk_audio_player.stop()
		return
	
	if GameState.rush: walk_audio_player.pitch_scale *= 1.5
	if  !walk_audio_player.playing: walk_audio_player.play()

func _on_walk_audio_player_finished():
	if audio_track == 0:
		walk_audio_player.stop()
		return
	var audio_rng = randi_range(0, 2)
	walk_audio_player.stream = GameState.FOOTSTEP_WOOD[audio_rng]
	walk_audio_player.play()
