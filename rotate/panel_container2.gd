extends PanelContainer

signal difficulty_selected(difficulty)


func _on_Button_pressed(difficulty:int):
	visible = false
	$"../HBoxContainer/Label/Label2".text = "Difficulty: "+$"VBoxContainer".get_child(difficulty+1).text
	
	emit_signal("difficulty_selected", difficulty)
