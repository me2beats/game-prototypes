extends Node2D

var tile_width = 64

var vals = {}

var used_cells = {}

var free_cells: =[]

var recent_idx:=-Vector2.ONE

var selected = []

var score = 0

var game_over = false

func gen_init_vals():
	for i in 8:
		for j in 8:
#			vals[Vector2(i,j)] = randi()%9+1
			vals[Vector2(j,i)] = randi()%9+1

	


func get_free_cell(col:int)->Vector2:

	if not free_cells:
		game_over = true
		
		return -Vector2.ONE


	for i in 8:

		if Vector2(col, i) in used_cells:
			return Vector2(col, i-1)

	return Vector2(col, 7)#



func add_random_tile():

	if not free_cells:
		game_over = true
		$UI/GameOver.show()
		return

#	var col = randi()%8
#	var free_cell = get_free_cell(col)
#	if free_cell == -Vector2.ONE:
#		return
#	add_tile(free_cell)

	# get_any_free_cell
	var free_cell =  free_cells[randi()%free_cells.size()]
	var col = free_cell[0]
	for i in range(7, -1, -1):
		if Vector2(col, i) in free_cells:
			add_tile(Vector2(col, i))
			return
			
#		if Vector2(col, row+i) in used_cells and not Vector2(col, row+1+i) in used_cells:




func add_tile(idx:Vector2):
	var tile = preload("tile.tscn").instance()

	tile.position = idx*tile_width
	add_child(tile)

	used_cells[idx] = tile
	free_cells.erase(idx)
	

func world_to_map(pos:Vector2):
	return (get_local_mouse_position()/tile_width).floor()

func select():
	var idx = world_to_map(get_local_mouse_position())
	if idx == recent_idx: return
	if not recent_idx == -Vector2.ONE and !recent_idx.distance_squared_to(idx) ==1: return


	var tile:Sprite = used_cells.get(idx)
	if not tile: return


	tile.texture = preload("tile_selected_texture.tres")


	selected.push_back(idx)
	recent_idx = idx


func deselect_all():

	for i in selected:
	
		var tile:Sprite = used_cells.get(i)
		if not tile: continue # why not exist?

		tile.texture = preload("tile_texture.tres")


	selected.clear()
	recent_idx=-Vector2.ONE

func del_selected():

	for i in selected:

		var tile:Sprite = used_cells.get(i)
		if not tile: continue # why not exist?

		tile.queue_free()

		used_cells.erase(i)
		free_cells.push_back(i)

#	selected.clear() #?
	

func _ready():
	for i in 8:
		for j in 8:
			free_cells.push_back(Vector2(i,j))

	
	for i in 12:
		add_random_tile()
		yield(get_tree().create_timer(0.3), "timeout")
		



func get_summ():
	var summ = 0
	for i in selected:
		summ+=used_cells[i].get_child(0).val
	return summ


# could be optimized
func move_tiles_down():
	for row in range(6, -1,-1):
		for col in 8:
			for i in 7:
				if row+i == 7: break

				if Vector2(col, row+i) in used_cells and not Vector2(col, row+1+i) in used_cells:

					yield(get_tree().create_timer(0.1), "timeout")
					var tile:Sprite = used_cells[Vector2(col, row+i)]
					tile.position.y+=tile_width
					used_cells.erase(Vector2(col, row+i))
					used_cells[Vector2(col, row+1+i)] = tile
					
					free_cells.push_back(Vector2(col, row+i))
					free_cells.erase(Vector2(col, row+1+i))


func _input(event:InputEvent):
	if event.is_action_pressed("reload game"):
		get_tree().reload_current_scene()
	
	if game_over: return
	
	if event is InputEventMouseMotion and event.button_mask:

		select()

	if event is InputEventMouseButton and !event.pressed:
		if get_summ() == 10:

			# update score
			score+=10
			$"UI/Label".text = "Score: "+str(score)
			
			del_selected()
			
			deselect_all()

#			yield(get_tree().create_timer(0.4), "timeout")
			
			var result = move_tiles_down()
			if result is GDScriptFunctionState:
				yield(result, "completed")

			
			yield(get_tree().create_timer(0.4), "timeout")
			
			for i in 3:
				add_random_tile()
				yield(get_tree().create_timer(0.3), "timeout")
			
		else:
			deselect_all()
		

	if event.is_action_pressed("ui_accept"):

		for i in 3:
			add_random_tile()
			yield(get_tree().create_timer(0.3), "timeout")
