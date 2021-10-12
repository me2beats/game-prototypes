extends Label

var val = randi()%9+1


func _ready():
	text = str(val)
