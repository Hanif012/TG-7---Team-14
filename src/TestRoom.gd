extends Node2D

@onready var player_character = $PlayerCharacter
@onready var camera = $Camera2D

func _on_player_character_player_moves():
	if abs(player_character.position.x) < 531:
		camera.position.x = player_character.position.x
