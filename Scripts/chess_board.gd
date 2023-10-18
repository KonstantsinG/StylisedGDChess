extends Node2D

@onready var cell_cursor = get_node("Cursors/CellCursor")
@onready var step_cursor = preload("res://Scenes/step_cursor.tscn")
@onready var kill_cursor = preload("res://Scenes/kill_cursor.tscn")
@onready var queen_white = preload("res://Scenes/Figures/queen_white.tscn")
@onready var queen_black = preload("res://Scenes/Figures/queen_black.tscn")
@onready var hand = get_node("Cursors/Hand")

const BOARD_INDXS = [
	Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)
]

var board : Array = []
var black_figures : Array = []
var white_figures : Array = []
var figure_in_hand = null
var is_player_step = true

var ai
var board_actions_handler


var target_coords = null
const SMOOTHNESS = 10
var target = null
var target_cell = null


func _ready():
	ai = Chess_AI.new()
	board_actions_handler = Board_actions_handler.new()
	
	set_board()
	
	var pawns = Figures_manager.setup_start_board("white", board)
	white_figures.append_array(pawns["white"])
	black_figures.append_array(pawns["black"])
	for i in pawns["white"]:
		get_cell(i.coords).add_child(i)
	for i in pawns["black"]:
		get_cell(i.coords).add_child(i)

func _process(_delta):
	control_custom_cursors()
	
	if not is_player_step:
		if $Timer.is_stopped():
			$Timer.start(1.5)

func _physics_process(delta):
	if target:
		var next_pos = target.position.lerp(target_coords, delta * SMOOTHNESS)
		_toggle_movement(next_pos)


func _toggle_movement(next_pos: Vector2):
	if next_pos != target.position:
		target.position = next_pos
	else:
		target.get_parent().remove_child(target)
		target_cell.add_child(target)
		target.update_coords(board)
		
		target_coords = null
		target.position = Vector2.ZERO
		target = null


# setup the board's starting parameters
func set_board():
	var cell_coords = Vector2.ZERO
	
	for cell in $Board.get_children():
		_setup_cell(cell, cell_coords)
		_check_figure(cell)
		
		cell_coords.x += 1
		if cell_coords.x == 8:
			cell_coords.x = 0
			cell_coords.y += 1


# setup a board cell
func _setup_cell(cell, cell_coords: Vector2):
	cell.coords = cell_coords
	cell.connect("gui_input", Callable(self, "cell_gui_input").bind(cell))
	board.append(cell)


# check for the presence of a black or white figure in a cell
func _check_figure(cell):
	if cell.get_child_count() > 0:
		if cell.get_child(0).team == "black":
			black_figures.append(cell.get_child(0))
		else:
			white_figures.append(cell.get_child(0))
		cell.get_child(0).update_coords(board)


# control custom mouse cursors
func control_custom_cursors():
	var local_mouse_pos = get_global_mouse_position() - $Cursors.position + Vector2(50, 50)
	
	#square cursor
	if local_mouse_pos.x > 0 and local_mouse_pos.x < 800:
		if local_mouse_pos.y > 0 and local_mouse_pos.y < 800:
			var offset = Vector2(int(local_mouse_pos.x / 100),  int(local_mouse_pos.y / 100))
			cell_cursor.position = offset * 100
			
			#hand cursor
			if local_mouse_pos.y > 500 and local_mouse_pos.y < 800:
				hand.position.y = local_mouse_pos.y
			hand.position.x = local_mouse_pos.x


# get gui input to define mouse clicks on a cell
func cell_gui_input(event : InputEvent, cell):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			if is_player_step:
				_process_cell_click(cell)


# handle clicking on a cell to make a decision
func _process_cell_click(cell):
	if not figure_in_hand: # ---------------------------------------- hand is free
		_check_take_state(cell)
	else: # --------------------------------------------------------- hand have the figure
		if cell.get_child_count() > 0: # ---------------------------- cell have the figure
			_check_switch_kill_drop_states(cell)
		else: # ----------------------------------------------------- cell is empty
			_check_drop_move_states(cell)


# check the possibility of taking a figure
func _check_take_state(cell):
	if cell.get_child_count() > 0: # -------------------------------- cell have the figure
			if cell.get_child(0).team == "white": # ----------------- figure is white
				#TAKE FIGURE
				figure_in_hand = cell.get_child(0)
				place_cursors()


# check switch, kill enemy or drop current figure
func _check_switch_kill_drop_states(cell):
	if cell.get_child(0).team == "white": # -------------------------- figure is white
		#SWITCH FIGURE
		figure_in_hand = cell.get_child(0)
		place_cursors()
	else: # ----------------------------------------------------------- figure is black
		if figure_in_hand.is_step_possible(cell.coords): # ------------ step possible
			#KILL ENEMY
			kill_figure(cell)
		else: # ------------------------------------------------------- step impossible
			#DROP FIGURE
			figure_in_hand = null
		clear_cursors()


# check drop or move current figure
func _check_drop_move_states(cell):
	if figure_in_hand.is_step_possible(cell.coords): # --------------- step possible
		#MOVE FIGURE
		move_figure(cell)
	else: # ---------------------------------------------------------- step impossible
		#DROP FIGURE
		figure_in_hand = null
	clear_cursors()


# move current figure to an another cell
func move_figure(cell):
	var prew_cell = figure_in_hand.get_parent()
	
	target = figure_in_hand
	target_coords = cell.position - prew_cell.position
	target_cell = cell
	
	figure_in_hand = null
	is_player_step = false


# process castling --------------------------------------------------------------------------------\
func make_castling(team: String, side: String):
	var castling_line
	
	if team == "white":
		castling_line = 7
	else: # black
		castling_line = 0
	
	move_rock_for_castling(side, castling_line)


# move the rook behind the king for castling ------------------------------------------------------\
# (using constant rocks positions agter castling)
func move_rock_for_castling(side: String, castling_line: int):
	var rock
	
	if side == "left":
		rock = get_cell(Vector2(0, castling_line)).get_child(0)
		rock.get_parent().remove_child(rock)
		get_cell(Vector2(3, castling_line)).add_child(rock)
	else: # right
		rock = get_cell(Vector2(7, castling_line)).get_child(0)
		rock.get_parent().remove_child(rock)
		get_cell(Vector2(5, castling_line)).add_child(rock)
		
	rock.update_coords(board)


# switch pawn that moved to another side of the board to queen ------------------------------------\
func swith_pawn_to_queen(pawn):
	var queen;
	var cell = pawn.get_parent()
	
	if pawn.team == "white":
		queen = queen_white.instantiate()
		white_figures.erase(pawn)
		white_figures.append(queen)
	else:
		queen = queen_black.instantiate()
		black_figures.erase(pawn)
		black_figures.append(queen)
	
	cell.remove_child(pawn)
	pawn.queue_free()
	cell.add_child(queen)
	queen.update_coords(board)


# move figure by AI
func move_figure_ai(figure, coords: Vector2):
	var cell = get_cell(coords)
	var prew_cell = figure.get_parent()
	
	check_kill_figure_ai(cell)
	
	target = figure
	target_coords = cell.position - prew_cell.position
	target_cell = cell
	is_player_step = true


# check is it possible to kill opposite figure by AI's figure
func check_kill_figure_ai(cell):
	var opposite_figure
	
	if cell.get_child_count() > 0:
		opposite_figure = cell.get_child(0)
		cell.remove_child(opposite_figure)
		white_figures.erase(opposite_figure)
		opposite_figure.queue_free()


# get a cell from the board by its coordinates
func get_cell(coords: Vector2):
	for i in board:
		if i.coords == coords:
			return i
	
	return null


# place on the board step or kill cursors for current figure
func place_cursors():
	var cursor
	var cell
	var steps = figure_in_hand.get_steps()
	
	clear_cursors()
	
	for line in steps:
		for coord in line:
			cell = get_cell(coord)
			if cell.get_child_count() > 0:
				cursor = kill_cursor.instantiate()
			else:
				cursor = step_cursor.instantiate()
			$Cursors/StepCursors.add_child(cursor)
			cursor.global_position = cell.global_position


# remove all cursors from the board
func clear_cursors():
	for i in $Cursors/StepCursors.get_children():
		$Cursors/StepCursors.remove_child(i)
		i.queue_free()


# kill opposite team figure by current figure
func kill_figure(cell):
	var opposite_figure = cell.get_child(0)
	
	black_figures.erase(opposite_figure)
	cell.remove_child(opposite_figure)
	opposite_figure.queue_free()
	move_figure(cell)


# get step from AI after passing a timer
func _on_ai_step_timer_timeout():
	var step = ai.get_random_model(black_figures)
	
	move_figure_ai(step["figure"], step["step"])


func check_shah(team: String, coords: Vector2) -> bool: #------------------------------------------\
	var figures
	
	if team == "white":
		figures = black_figures
	else:
		figures = white_figures
	
	for i in black_figures:
		if i.type == "pawn":
			pass
		else:
			if i.is_step_possible(coords):
				return false
	
	return true
