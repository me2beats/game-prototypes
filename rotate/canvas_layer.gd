extends CanvasLayer


func _input(event):
	if event.is_action_pressed("reload_game"):
		get_tree().reload_current_scene()
