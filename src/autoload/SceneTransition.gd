extends CanvasLayer



func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0,0,0,0), 0.5)
	
func change_scene(scene_name: String) -> void:
	$ColorRect.color = Color(0,0,0,1)
	PlayerState.transition_state = true

	var scene_path = "res://src/rooms/" + scene_name + ".tscn"
	get_tree().change_scene_to_file(scene_path)
	
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0,0,0,0), 0.5)
	await tween.finished
	
	PlayerState.transition_state = false
