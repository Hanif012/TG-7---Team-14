extends Node2D

func _ready():
	MusicManager.music_track = 3

func _on_button_pressed():
	get_tree().change_scene_to_file("res://src/menu/MainMenu.tscn")
