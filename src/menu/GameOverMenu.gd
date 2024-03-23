extends Node2D

func _ready():
	$ScreamSFX.play_sound()
	MusicManager.music_track = 0
	await get_tree().create_timer(3).timeout
	MusicManager.music_track = 4

func _on_button_pressed():
	get_tree().change_scene_to_file("res://src/menu/MainMenu.tscn")
