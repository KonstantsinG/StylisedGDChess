extends Chess_figure

var is_first_step = true
var steps_direction
var parent
var opposite_side


func _ready():
	team = "black"
	type = "pawn"
	steps = [[], []]
	parent = self.get_parent()
	steps_direction = 1
	opposite_side = 7


# update figure local coords relative board
func update_coords(global_board : Array):
	board = global_board
	coords = self.get_parent().coords
	
	if is_first_step and parent != self.get_parent():
		is_first_step = false
	
	if coords.y == opposite_side:
		get_viewport().get_node("Chess board").swith_pawn_to_queen(self)


# get steps by unique pattern for current figure
func get_steps_by_pattern():
	steps[0].append(coords + Vector2(0, 1) * steps_direction)
	if is_first_step:
		steps[0].append(coords + Vector2(0, 2) * steps_direction)
	
	steps[1].append(coords + Vector2(1, 1) * steps_direction)
	steps[1].append(coords + Vector2(-1, 1) * steps_direction)


# find extra coords in the line blocked by another figure
func find_blocked_coords(corpses: Array[Vector2]):
	find_blocked_step_coords(corpses)
	find_blocked_kill_coords(corpses)


# find step coords blocked by another figure
func find_blocked_step_coords(corpses: Array[Vector2]):
	var cell
	var obsticle = false
	
	for coord in steps[0]:
		if not corpses.has(coord):
			if obsticle:
				corpses.append(coord)
			else:
				cell = get_cell(coord)
				if cell.get_child_count() > 0:
					corpses.append(coord)
					obsticle = true


# find empty or blocked kill coords by an ally's figure
func find_blocked_kill_coords(corpses: Array[Vector2]):
	var cell
	
	for coord in steps[1]:
		if not corpses.has(coord):
			cell = get_viewport().get_node("Chess board").get_cell(coord)
			if cell.get_child_count() > 0:
				if cell.get_child(0).team == team:
					corpses.append(coord)
			else:
				corpses.append(coord)
