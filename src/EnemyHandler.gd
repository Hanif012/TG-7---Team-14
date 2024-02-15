extends Node

@onready var characters = get_parent().get_node("Characters")

var enemy = preload("res://src/Enemy.tscn")

func _ready():
	GameState.enemy_meet_up.connect(spawn_enemy_in_room)

func run_enemy_handler():
	match GameState.monster_state:
		GameState.MonsterState.ROAMING: enemy_roaming()
		GameState.MonsterState.CHASE:
			print(GameState.Room.keys()[GameState.enemy_location], GameState.Room.keys()[GameState.player_location])
			if GameState.enemy_location != GameState.player_location:
				print("same room 1")
				await get_tree().create_timer(1.0).timeout
				spawn_enemy_in_room()
				print("same room 2")
			print("finished running chase case")
	



func enemy_roaming():
	#		print(GameState.time_left)
	if GameState.time_left != GameState.DEFAULT_MONSTER_TIMER && GameState.time_left  > 0:
		%EnemyMovementTimer.wait_time = GameState.time_left
		%EnemyMovementTimer.start()
		
		await %EnemyMovementTimer.timeout
		%EnemyMovementTimer.wait_time = GameState.DEFAULT_MONSTER_TIMER
	
	%EnemyMovementTimer.one_shot = false
	%EnemyMovementTimer.start()

func _on_enemy_movement_timer_timeout():
	GameState.enemy_location = (randi() % len(GameState.Room)) as GameState.Room
	print(GameState.Room.keys()[GameState.enemy_location])
	GameState.check_if_meet_up()
	
func spawn_enemy_in_room():
	%EnemyMovementTimer.stop()
	print("MEET UP")
	
	GameState.enemy_location = GameState.player_location
	var enemy_node = enemy.instantiate()
	characters.add_child(enemy_node)
	pass
