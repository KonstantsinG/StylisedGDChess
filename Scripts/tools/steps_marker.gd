class_name Steps_marker
extends Node

# this class takes two-dimensional array of figures and its steps coordinates
# and return array of dictionaries for each figure, that contain markers for
# every step. For example: stepA - normal_step, stepB - short_castling,
# stepC - turning_pawn_into_a_queen and so on...

var markers = [
	"NORMAL",
	"SHORT_CASTLING", "LONG_CASTLING",
	"TURN_PAWN_TO_QUEEN",
	"CHECK", "CHECKMATE"
]


func mark_steps(figures: Array, steps: Array[Array]):
	var marked_steps: Array[Dictionary]
	var steps_line: Dictionary
	
	for figure_num in range(figures.size()):
		steps_line.clear()
		for step in steps[figure_num]:
			if figures[figure_num].type == "king":
				pass
			else:
				pass


func check_castling(figure, step: Vector2) -> String:
	if figure.coords.x - step.x == 2: # left
		return "LONG_CASTLING"
	elif figure.coords.x - step.x == -2: # right
		return "SHORT_CASTLING"
	else:
		return "NORMAL"


func check_turn_pawn(pawn, step: Vector2) -> String:
	if pawn.team == "white":
		if step.y == 0:
			return "TURN_PAWN_TO_QUEEN"
	else:
		if step.y == 7:
			return "TURN_PAWN_TO_QUEEN"
	
	return "NORMAL"
