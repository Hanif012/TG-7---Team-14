extends Node

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

@onready var main_menu_control = $CanvasLayer/MainMenuControl
@onready var option_control = $CanvasLayer/OptionControl
@onready var music_slider = $CanvasLayer/OptionControl/MarginContainer/VBoxContainer/GridContainer/MusicSlider
@onready var sfx_slider = $CanvasLayer/OptionControl/MarginContainer/VBoxContainer/GridContainer/SFXSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.music_track = 0
	music_slider.value = GameState.music_slider_value
	sfx_slider.value = GameState.sfx_slider_value

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)
	GameState.music_slider_value = value

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)
	GameState.sfx_slider_value = value

func _on_play_pressed():
	GameState.restart_game()
	get_tree().change_scene_to_file("res://src/rooms/Bedroom.tscn")

func _on_options_pressed():
	main_menu_control.hide()
	option_control.show()

func _on_return_pressed():
	main_menu_control.show()
	option_control.hide()

func _on_quit_pressed():
	get_tree().quit()
