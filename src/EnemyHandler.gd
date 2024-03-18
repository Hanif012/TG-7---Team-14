extends Node

@onready var characters = get_parent().get_node("Characters")
@onready var room = get_parent()

var enemy = preload("res://src/Enemy.tscn")

@onready var lost_track_timer : Timer = $LostTrackTimer
@onready var enemy_movement_timer : Timer  = $EnemyMovementTimer

func _ready():
	GameState.enemy_meet_up.connect(spawn_enemy_in_room)

func run_enemy_handler():
	match GameState.enemy_state:
		GameState.EnemyState.ROAMING: enemy_roaming()
		GameState.EnemyState.CHASING: enemy_chasing()
		GameState.EnemyState.FINAL: enemy_final()
		GameState.EnemyState.LOSTTRACK:
			if GameState.enemy_location != GameState.player_location || GameState.hiding_state:
				GameState.enemy_location = GameState.last_player_location
				lost_track_timer.start()
				await lost_track_timer.timeout
				if GameState.enemy_state == GameState.EnemyState.LOSTTRACK:
					GameState.enemy_state = GameState.EnemyState.ROAMING
					enemy_roaming()
			else:
				GameState.enemy_state = GameState.EnemyState.CHASING
				if characters.get_child_count() > 1:
					spawn_enemy_in_room(GameState.player_position)

func enemy_roaming():
	if GameState.time_left != GameState.DEFAULT_MONSTER_TIMER && GameState.time_left  > 0:
		enemy_movement_timer.wait_time = GameState.time_left
		enemy_movement_timer.start()
		
		await enemy_movement_timer.timeout
		enemy_movement_timer.wait_time = GameState.DEFAULT_MONSTER_TIMER
	
	enemy_movement_timer.one_shot = false
	enemy_movement_timer.start()

func enemy_chasing():
	if GameState.enemy_location != GameState.player_location:
		await get_tree().create_timer(1.0 + float(GameState.enemy_distance)/300.0).timeout
		spawn_enemy_in_room(GameState.player_position)

func enemy_final():
	await get_tree().create_timer(1.0).timeout
	spawn_enemy_in_room(GameState.player_position)

func _on_enemy_movement_timer_timeout():
	if GameState.enemy_state != GameState.EnemyState.FINAL:
		GameState.enemy_location = randi_range(0, len(GameState.Room)-1) as GameState.Room
	#	GameState.enemy_location = GameState.Room.BEDROOM
	#	print(GameState.Room.keys()[GameState.enemy_locat 	ion])
		GameState.check_if_meet_up()
	else:
		enemy_movement_timer.stop()
		
	
func spawn_enemy_in_room(spawn_position: float = 0):
	if GameState.enemy_state == GameState.EnemyState.ROAMING:
		enemy_movement_timer.stop()
		spawn_position = room.door_positions[randi_range(0,len(room.door_positions)-1)]
	
	GameState.enemy_location = GameState.player_location
	if characters.get_child_count() == 1: 
		var enemy_node = enemy.instantiate()
		enemy_node.position.x = spawn_position
		characters.add_child(enemy_node)
