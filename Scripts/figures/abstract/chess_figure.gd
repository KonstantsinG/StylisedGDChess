class_name Chess_figure
extends Node

@export_enum("white", "black") var team
@export_enum("pawn", "rock", "horse", "beshop", "queen", "king") var type
var coords : Vector2
var steps : Array[Array]
var board : Array


# update figure local coords relative board
func update_coords(global_board):
	board = global_board
	coords = self.get_parent().coords


# get possible steps for figure
func get_steps() -> Array[Array]:
	clear_steps()
	get_steps_by_pattern()
	remove_incorrect_coords()
	
	return steps


# put there unique steps pattern code
func get_steps_by_pattern():
	pass


# clear steps array
func clear_steps():
	for arr in steps:
		arr.clear()


# check whether a step to the current coordinate is possible
func is_step_possible(cell_coord: Vector2) -> bool:
	var local_steps = get_steps()
	
	for line in local_steps:
		for coord in line:
			if coord == cell_coord:
				return true
	
	return false


# remove incorrect coords from possible_steps array
func remove_incorrect_coords():
	var corpses : Array[Vector2] = []
	
	find_coords_out_of_the_board(corpses)
	find_blocked_coords(corpses)
	
	for corp in corpses:
		for line in steps:
			if line.has(corp):
				line.erase(corp)


# find coord, that lie out of the board
func find_coords_out_of_the_board(corpses: Array[Vector2]):
	for line in steps:
		for coord in line:
			if coord.x > 7 or coord.x < 0:
				corpses.append(coord)
			elif coord.y > 7 or coord.y < 0:
				corpses.append(coord)


# find extra coords in the line blocked by another figure
func find_blocked_coords(corpses: Array[Vector2]):
	var cell
	var obsticle = false
	
	for line in steps:
		obsticle = false
		for coord in line:
			if not corpses.has(coord):
				cell = get_cell(coord)
				if obsticle:
					corpses.append(coord)
				elif cell.get_child_count() > 0:
					if cell.get_child(0).team == self.team:
						corpses.append(coord)
					obsticle = true


# get a cell from the board by its coordinates
func get_cell(cell_coords):
	for i in board:
		if i.coords == cell_coords:
			return i
	
	return null
