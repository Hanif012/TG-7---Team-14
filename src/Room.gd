extends Node2D

@onready var player_character = $PlayerCharacter
@onready var camera = $Camera2D

@onready var left_border = $Background/LetBorder
@onready var right_border = $Background/RightBorder

func _process(_delta):
	if player_character.position.x >= 0:
		camera.position.x = min(max(right_border.position.x  - (1280/4), 0), player_character.position.x)
	else:
		camera.position.x = max(min(left_border.position.x  + (1280/4), 0), player_character.position.x)

		
