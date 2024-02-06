extends Node

@onready var characters = get_parent().get_node("Characters")

var enemy = preload("res://src/Enemy.tscn")

func _ready():
	match GameState.monster_state:
		GameState.MonsterState.ROAMING:
			GameState.enemy_meet_up.connect(spawn_enemy_in_room)
	#		print(GameState.time_left)
			if GameState.time_left != GameState.DEFAULT_MONSTER_TIMER && GameState.time_left  > 0:
				%EnemyMovementTimer.wait_time = GameState.time_left
				%EnemyMovementTimer.start()
				
				await %EnemyMovementTimer.timeout
				%EnemyMovementTimer.wait_time = GameState.DEFAULT_MONSTER_TIMER
			
			%EnemyMovementTimer.one_shot = false
			%EnemyMovementTimer.start()
		GameState.MonsterState.CHASE:
			spawn_enemy_in_room()

func _on_enemy_movement_timer_timeout():
	GameState.enemy_location = (randi() % len(GameState.Room))+1
#	print(GameState.Room.keys()[GameState.enemy_location])
	
func spawn_enemy_in_room():
	%EnemyMovementTimer.stop()
	print("MEET UP")
	var enemy_node = enemy.instantiate()
	characters.add_child(enemy_node)
	pass
