extends Node2D

const EDGE_ZONE = int(1280/4.0)
const DOOR_AUDIO_PATH : Array[String] = [
	"res://assets/audio/sfx/SFX_Door_1.ogg",
	"res://assets/audio/sfx/SFX_Door_2.ogg",
	"res://assets/audio/sfx/SFX_Door_3.ogg"
]
@export var room_id := GameState.Room.ATTIC
@export var door_positions : Array[float] = []

@onready var player_character = %Player
@onready var camera = $Camera2D

@onready var left_border = $Borders/LeftBorder
@onready var right_border = $Borders/RightBorder
@onready var fade_out_mask = $UI/Control/FadeOut
@onready var enemy_handler = $EnemyHandler

@onready var open_desk : SoundQueue = $OpenDeskQueue
@onready var open_cabinet : SoundQueue = $OpenCabinetQueue
@onready var door_audio_player : AudioStreamPlayer = $DoorAudioPlayer


func _ready() -> void:
	GameState.emit_sound.connect(play_search_sound)
	if GameState.game_start:
		GameState.game_start = false
	else:
		GameState.emit_sound.emit("Door")
	GameState.transition_state = true
	GameState.player_location = room_id
	name = "Room"
	GameState.check_if_meet_up()
	enemy_handler.run_enemy_handler()
	
	fade_out_mask.color = Color(0,0,0,1)
	var tween = get_tree().create_tween()
	tween.tween_property(fade_out_mask, "color", Color(0,0,0,0), 0.5)
	await tween.finished
	
	GameState.transition_state = false
	

func play_search_sound(str: String = "Desk"):
	match str:
		"Desk": open_desk.play_sound()
		"Cabinet": open_cabinet.play_sound()
		"Door": 
			door_audio_player.stream = load(DOOR_AUDIO_PATH[randi_range(0, len(DOOR_AUDIO_PATH)-1)])
			door_audio_player.playing = true
		_: pass


func _process(_delta) -> void:
	if player_character.position.x >= 0:
		camera.position.x = min(max(right_border.position.x  - EDGE_ZONE, 0), player_character.position.x)
	else:
		camera.position.x = max(min(left_border.position.x  + EDGE_ZONE, 0), player_character.position.x)
