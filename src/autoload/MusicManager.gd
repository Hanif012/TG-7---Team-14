extends Node

const MUSIC_ROAMING = preload("res://assets/audio/music/Music_Ambience.ogg")
const MUSIC_CHASING = preload("res://assets/audio/music/Music_Chase.ogg")
const MUSIC_VICTORY = preload("res://assets/audio/music/Music_Finish.ogg")
const MUSIC_GAME_OVER = preload("res://assets/audio/music/Music_Game_Over.ogg")

@onready var music_player : AudioStreamPlayer = $MusicPlayer

var music_track : int = -1 :
	set(value):
		if value != music_track:
			update_music_player(value)
		music_track = value

func set_track(value: GameState.EnemyState):
	if GameState.game_running:
		match value:
			GameState.EnemyState.ROAMING:
				music_track = 1
			GameState.EnemyState.CHASING, GameState.EnemyState.FINAL, GameState.EnemyState.LOSTTRACK:
				music_track = 2

func update_music_player(value):
	music_player.stop()
	match value:
		1: music_player.stream = MUSIC_ROAMING
		2: music_player.stream = MUSIC_CHASING
		3: music_player.stream = MUSIC_VICTORY
		4: music_player.stream = MUSIC_GAME_OVER
		_: music_player.stream = null
	if value != 0: music_player.play()
	else: music_player.stop()
