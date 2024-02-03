extends Node

@onready var characters = get_parent().get_node("Characters")

var enemy = preload("res://src/Enemy.tscn")

func _ready():
	GameState.enemy_meet_up.connect(spawn_enemy_in_room)
	print(GameState.remaining_time)
	if GameState.remaining_time != GameState.DEFAULT_MONSTER_TIMER:
		%EnemyMovementTimer.wait_time = GameState.remaining_time
		%EnemyMovementTimer.start()
		
		await %EnemyMovementTimer.timeout
		%EnemyMovementTimer.wait_time = GameState.DEFAULT_MONSTER_TIMER
	
	%EnemyMovementTimer.one_shot = false
	%EnemyMovementTimer.start()

func _on_enemy_movement_timer_timeout():
	GameState.enemy_location = (randi() % len(GameState.Room))+1

func spawn_enemy_in_room():
	%EnemyMovementTimer.stop()
	print("MEET UP")
	var enemy_node = enemy.instantiate()
	characters.add_child(enemy_node)
	pass
