extends Node

@onready var characters = get_parent().get_node("Characters")
@onready var room = get_parent()

var enemy = preload("res://src/Enemy.tscn")

func _ready():
	GameState.enemy_meet_up.connect(spawn_enemy_in_room)

func run_enemy_handler():
	match GameState.enemy_state:
		GameState.EnemyState.ROAMING: enemy_roaming()
		GameState.EnemyState.CHASING: enemy_chasing()
		GameState.EnemyState.LOSTTRACK:
			if GameState.enemy_location != GameState.player_location:
				GameState.enemy_location = GameState.last_player_location
				%LostTrackTimer.start()
				await %LostTrackTimer.timeout
				enemy_roaming()
			else:
				GameState.enemy_state = GameState.EnemyState.CHASING
				spawn_enemy_in_room(GameState.player_position)

func enemy_roaming():
	if GameState.time_left != GameState.DEFAULT_MONSTER_TIMER && GameState.time_left  > 0:
		%EnemyMovementTimer.wait_time = GameState.time_left
		%EnemyMovementTimer.start()
		
		await %EnemyMovementTimer.timeout
		%EnemyMovementTimer.wait_time = GameState.DEFAULT_MONSTER_TIMER
	
	%EnemyMovementTimer.one_shot = false
	%EnemyMovementTimer.start()

func enemy_chasing():
	if GameState.enemy_location != GameState.player_location:
		await get_tree().create_timer(GameState.enemy_distance/300).timeout
		spawn_enemy_in_room(GameState.player_position)

func _on_enemy_movement_timer_timeout():
	GameState.enemy_location = randi_range(0, len(GameState.Room)-1) as GameState.Room
	print(GameState.Room.keys()[GameState.enemy_location])
	GameState.check_if_meet_up()
	
func spawn_enemy_in_room(spawn_position: float = 0):
	if GameState.enemy_state == GameState.EnemyState.ROAMING:
		%EnemyMovementTimer.stop()
		spawn_position = room.door_positions[randi_range(0,len(room.door_positions)-1)]
	
	GameState.enemy_location = GameState.player_location
	var enemy_node = enemy.instantiate()
	enemy_node.position.x = spawn_position
	characters.add_child(enemy_node)
