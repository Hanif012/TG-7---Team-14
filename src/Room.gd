extends Node2D

const EDGE_ZONE = int(1280/4.0)
@onready var player_character = $PlayerCharacter
@onready var camera = $Camera2D

@onready var left_border = $Borders/LetBorder
@onready var right_border = $Borders/RightBorder


func _process(_delta):
	if player_character.position.x >= 0:
		camera.position.x = min(max(right_border.position.x  - EDGE_ZONE, 0), player_character.position.x)
	else:
		camera.position.x = max(min(left_border.position.x  + EDGE_ZONE, 0), player_character.position.x)
