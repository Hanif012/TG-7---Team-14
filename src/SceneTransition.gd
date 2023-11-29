extends CanvasLayer



func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0,0,0,0), 0.5)
	
func change_screen(path: String) -> void:
	PlayerState.transition_state = true
	$ColorRect.color = Color(0,0,0,1)
	get_tree().change_scene_to_file(path)
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0,0,0,0), 0.5)
	
	
	await tween.finished
	PlayerState.transition_state = false
