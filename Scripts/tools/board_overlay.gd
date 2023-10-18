class_name Board_overlay
extends Node

# this class completely break encapsulation between board and figures.

const PAWN_TURNING_Y ={
	"white" : 0,
	"black" : 7}
const KING_LONG_CASTLING = {
	"white" : Vector2(2, 7),
	"black" : Vector2(2, 0)}
const KING_SHORT_CASTLING = {
	"white" : Vector2(6, 7),
	"black" : Vector2(6, 0)}

var board_ref
var previeous_board: Array
var new_gen_board: Array


func _init(board_itself):
	board_ref = board_itself


func check_last_step(figure):
	if figure.type == "pawn":
		check_pawn_turning_into_a_queen(figure)
	elif  figure.type == "king":
		check_king_make_castling(figure)


func check_pawn_turning_into_a_queen(pawn):
	if pawn.coords == PAWN_TURNING_Y[pawn.team]:
		board_ref.make_castling()


func check_king_make_castling(king):
	pass
