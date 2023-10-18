class_name Figures_manager
extends Node

var black_pos = -1;
var white_pos = 1;


static func setup_start_board(player_team: String, global_board: Array) -> Dictionary:
	var board: Dictionary
	var white_figures: Array
	var black_figures: Array
	var player_pos
	var enemy_pos
	
	if player_team == "white":
		player_pos = 6;
		enemy_pos = 1;
	else:
		player_pos = 1;
		enemy_pos = 6;
	
	for i in range(0, 8):
		white_figures.append(Pawn.get_instance("white", Vector2(i, player_pos), global_board))
		black_figures.append(Pawn.get_instance("black", Vector2(i, enemy_pos), global_board))
	
	board = {"white" : white_figures, "black" : black_figures}
	return board
