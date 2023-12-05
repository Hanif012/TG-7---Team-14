extends Node2D

const EDGE_ZONE = int(1280/4.0)
@onready var player_character = $PlayerCharacter
@onready var camera = $Camera2D

@onready var left_border = $Borders/LeftBorder
@onready var right_border = $Borders/RightBorder
@onready var fade_out_mask = $UI/Control/FadeOut

func _ready() -> void:
	GameState.transition_state = true
	fade_out_mask.color = Color(0,0,0,1)
	var tween = get_tree().create_tween()
	tween.tween_property(fade_out_mask, "color", Color(0,0,0,0), 0.5)
	await tween.finished
	
	GameState.transition_state = false

func _process(_delta) -> void:
	if player_character.position.x >= 0:
		camera.position.x = min(max(right_border.position.x  - EDGE_ZONE, 0), player_character.position.x)
	else:
		camera.position.x = max(min(left_border.position.x  + EDGE_ZONE, 0), player_character.position.x)
