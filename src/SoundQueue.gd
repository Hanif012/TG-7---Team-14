@tool
extends Node

var _next := 0
var _audio_stream_players: Array[AudioStreamPlayer]

@export var COUNT := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() == 0:
		print("No AudioStreamPlayer child found.")
		return
	
	var child = get_child(0)
	if (child is AudioStreamPlayer):
		_audio_stream_players.append(child)
		for n in range(COUNT-1):
			var duplicated_node = child.duplicate()
			add_child(duplicated_node)
			_audio_stream_players.append(duplicated_node)


func _get_configuration_warnings():
	if get_child_count() == 0:
		return ["No children found. Expected one AudioStreamPlayer child."]
	elif !(get_child(0) is AudioStreamPlayer):
		return ["Expected first child to be AudioStreamPlayer."]
	else:
		return []


func play_sound() -> void:
	if !_audio_stream_players[_next].playing:
		_audio_stream_players[_next].play()
		_next = (_next + 1) % COUNT
