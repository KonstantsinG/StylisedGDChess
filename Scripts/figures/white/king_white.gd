extends Chess_figure

var parent
var is_first_step = true

func _ready():
	team = "white"
	type = "king"
	steps = [[], []]
	parent = self.get_parent()


# update figure local coords relative board
func update_coords(global_board : Array):
	board = global_board
	is_castling_happends()
	coords = self.get_parent().coords
	
	if is_first_step and parent != self.get_parent():
		is_first_step = false


# bad stuff
# must remove hard links to main board
# in kings and pawns
# remade this by using a signals
func is_castling_happends():
	if coords.x - self.get_parent().coords.x == 2: # left
		get_viewport().get_node("Chess board").make_castling(team, "left")
	elif coords.x - self.get_parent().coords.x == -2: # right
		get_viewport().get_node("Chess board").make_castling(team, "right")


# get steps by unique pattern for current figure
func get_steps_by_pattern():
	if is_first_step:
		var castling_coords = check_castling()
		if not castling_coords.is_empty():
			steps[1].append_array(castling_coords)
	
	steps[0].append(coords + Vector2(0, -1))
	steps[0].append(coords + Vector2(1, -1))
	steps[0].append(coords + Vector2(1, 0))
	steps[0].append(coords + Vector2(1, 1))
	steps[0].append(coords + Vector2(0, 1))
	steps[0].append(coords + Vector2(-1, 1))
	steps[0].append(coords + Vector2(-1, 0))
	steps[0].append(coords + Vector2(-1, -1))


func check_castling() -> Array[Vector2]:
	var castling_steps : Array[Vector2] = []
	var cell_left = get_cell(Vector2(0, 7))
	var cell_right = get_cell(Vector2(7, 7))
	
	if cell_left.get_child_count() > 0:
		if cell_left.get_child(0).is_first_step:
			castling_steps.append(coords + Vector2(-2, 0))
	
	if cell_right.get_child_count() > 0:
		if cell_right.get_child(0).is_first_step:
			castling_steps.append(coords + Vector2(2, 0))
	
	return castling_steps


# remove incorrect coords from possible_steps array
func remove_incorrect_coords():
	var corpses : Array[Vector2] = []
	
	find_coords_out_of_the_board(corpses)
	find_blocked_coords(corpses)
	find_check_coords(corpses)
	
	if not steps[1].is_empty():
		find_blocked_castling_coords(corpses)
	
	for corp in corpses:
		for line in steps:
			if line.has(corp):
				line.erase(corp)


# find extra coords in the line blocked by another figure
func find_blocked_coords(corpses: Array[Vector2]):
	var cell
	
	for coord in steps[0]:
		if not corpses.has(coord):
			cell = get_cell(coord)
			if cell.get_child_count() > 0:
				if cell.get_child(0).team == team:
					corpses.append(coord)


func find_blocked_castling_coords(corpses: Array[Vector2]):
	var cell
	
	for st in steps[1]:
		if st.x == 2:
			for i in range (1, 4):
				cell = get_cell(coords + Vector2(-i, 0))
				if cell.get_child_count() > 0:
					corpses.append(st)
		else:
			for i in range (1, 3):
				cell = get_cell(coords + Vector2(i, 0))
				if cell.get_child_count() > 0:
					corpses.append(st)


func find_check_coords(corpses: Array[Vector2]):
	for line in steps:
		for coord in line:
			if not corpses.has(coord):
				if not get_viewport().get_node("Chess board").check_shah(team, coord):
					corpses.append(coord)
