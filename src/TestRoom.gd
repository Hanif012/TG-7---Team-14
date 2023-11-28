extends Node2D

@onready var player_character = $PlayerCharacter
@onready var camera = $Camera2D

func _process(_delta):
	if player_character.position.x >= 0:
		camera.position.x = min(1000, player_character.position.x)
	else:
		camera.position.x = max(-1000, player_character.position.x)

		
