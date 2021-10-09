extends TileMap

var selected = []

onready var score_label:Label = $"../CanvasLayer/HBoxContainer/Label"
onready var game_over_panel = $"../CanvasLayer/PanelContainer"

var score = 0

var difficulty = 1

export var color = Color(0.314941, 0.530829, 0.9375)

func _draw():
	for pos in selected:
		draw_rect(Rect2(pos.x, pos.y, 64,64).grow(8), color)

func get_cell_pos_in_map():
	return world_to_map(get_local_mouse_position())

func get_cell_pos_at_mouse(): 
	return map_to_world(world_to_map(get_local_mouse_position()))

const tile_rot = {
	[false,false,false]:[true,false,true],
	[true,false,true]:[false,true,false],
	[false,true,false]:[false,true,true],
	[false,true,true]:[false,false,false]
	
	
#	[0,0,0]:[0,0,1] # left

}

func rotate90(cell:Vector2, tile = null):
	if not tile:
		tile = get_cellv(cell)

	var new_rot_data = tile_rot[get_rotation_info(cell)]
	var new_flip_x = new_rot_data[0]
	var new_flip_y = new_rot_data[1]
	var new_transp = new_rot_data[2]
	set_cellv(cell, tile, new_flip_x, new_flip_y, new_transp)


var free_cells = []

func init_free_cells():
	for i in 8:
		for j in 8:
			free_cells.push_back(Vector2(i, j))


func add_random():
	if not free_cells:
		game_over_panel.get_node("Label").text = """Game over!
Your score: """+str(score)+"""
Press F5 to restart"""
		game_over_panel.visible = true
		set_process_input(0)
		return
	
	var i = randi()%free_cells.size()
	
	var random_rot = tile_rot.keys()[randi()%4]
	
	set_cellv(free_cells[i], 0, random_rot[0], random_rot[1], random_rot[2])

	free_cells.remove(i)


func _ready():
	randomize()
	
	var difficulty = yield($"../CanvasLayer/PanelContainer2", "difficulty_selected")
	self.difficulty = difficulty
	
	init_free_cells()

	for i  in 3*(difficulty+1):
		yield(get_tree().create_timer(0.1),"timeout")
		add_random()



func _input(event):
	if event.is_action_pressed("click"):
		var pos = get_cell_pos_at_mouse()
#		if pos in selected: return
		if pos in selected:
			# unselect
			selected.erase(pos)
			update()
			return
		var pos_in_map = get_cell_pos_in_map()
		var cell = get_cellv(pos_in_map)
		if cell == -1: return

		selected.push_back(pos)
		update()




	if event.is_action_pressed("ui_accept"):
		if selected.size() ==0: 
			# skip move
			for i in 3*(difficulty+1):
				add_random()
				yield(get_tree().create_timer(0.1),"timeout")
			remove_3_neighbours()
			return
			
		if selected.size() ==1: return
		
		for pos_ in selected:
			rotate90(world_to_map(pos_), 0)
		
		for i in 3*(difficulty+1):
			yield(get_tree().create_timer(0.1),"timeout")
			add_random()

		selected.clear()
		update()

		yield(get_tree().create_timer(0.5),"timeout")

		remove_3_neighbours()


		


const dirs = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]


func get_rotation_info(cell:Vector2):
	var x = cell.x
	var y= cell.y
	return [is_cell_x_flipped(x, y), is_cell_y_flipped(x, y), is_cell_transposed(x,y)]

func remove_neighbours():
	var cells_to_remove = {}
	var used_cells = get_used_cells()
	for i in used_cells:
		for dir in dirs:
			if i+dir in used_cells and get_rotation_info(i) == get_rotation_info(i+dir):
				cells_to_remove[i+dir] = true

	score+=cells_to_remove.size()
	score_label.text = 'Score: '+ str(score)

	for cell in cells_to_remove:
		set_cellv(cell, -1)
		free_cells.push_back(cell)
	print(free_cells.size())
		
	
func remove_3_neighbours():
	var cells_to_remove = {}
	var used_cells = get_used_cells()
	for i in used_cells:
		for dir in dirs:
			if i+dir in used_cells and get_rotation_info(i) == get_rotation_info(i+dir):
				var i_ = i+dir
				for dir_ in dirs:
					if !i_+dir_==i and i_+dir_ in used_cells and get_rotation_info(i_) == get_rotation_info(i_+dir_):
						
						cells_to_remove[i] = true
						cells_to_remove[i+dir] = true
						cells_to_remove[i_+dir_] = true
						

	score+=cells_to_remove.size()
	score_label.text = 'Score: '+ str(score)

	for cell in cells_to_remove:
		set_cellv(cell, -1)
		free_cells.push_back(cell)
	print(free_cells.size())
