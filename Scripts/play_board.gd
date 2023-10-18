extends Node2D

@onready var cell_cursor = get_node("Cursors/CellCursor")
@onready var step_cursor = preload("res://Scenes/step_cursor.tscn")
@onready var kill_cursor = preload("res://Scenes/kill_cursor.tscn")
@onready var queen_white = preload("res://Scenes/Figures/queen_white.tscn")
@onready var queen_black = preload("res://Scenes/Figures/queen_black.tscn")
@onready var hand = get_node("Cursors/Hand")

var board : Array = []
var black_figures : Array = []
var white_figures : Array = []
var figure_in_hand = null
var is_player_step = true


func _ready():
	set_board()

func _process(_delta):
	control_custom_cursors()
	
	if not is_player_step:
		var ai = Chess_AI.new()
		var step = ai.get_random_step(black_figures)
		
		move_figure_ai(step["figure"], step["step"])


# setup the board's starting parameters
func set_board():
	var cell_coords = Vector2.ZERO
	
	for cell in $Board.get_children():
		setup_cell(cell, cell_coords)
		check_figure(cell)
		
		cell_coords.x += 1
		if cell_coords.x == 8:
			cell_coords.x = 0
			cell_coords.y += 1


# setup a board cell
func setup_cell(cell, cell_coords):
	cell.coords = cell_coords
	cell.connect("gui_input", Callable(self, "cell_gui_input").bind(cell))
	board.append(cell)


# check for the presence of a black or white figure in a cell
func check_figure(cell):
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
				process_cell_click(cell)


# handle clicking on a cell to make a decision
func process_cell_click(cell):
	if not figure_in_hand: # ---------------------------------------- hand is free
		check_take_state(cell)
	else: # --------------------------------------------------------- hand have the figure
		if cell.get_child_count() > 0: # ---------------------------- cell have the figure
			check_switch_kill_drop_states(cell)
		else: # ----------------------------------------------------- cell is empty
			check_drop_move_states(cell)


# check the possibility of taking a figure
func check_take_state(cell):
	if cell.get_child_count() > 0: # -------------------------------- cell have the figure
			if cell.get_child(0).team == "white": # ----------------- figure is white
				#TAKE FIGURE
				figure_in_hand = cell.get_child(0)
				place_cursors()


# check switch, kill enemy or drop current figure
func check_switch_kill_drop_states(cell):
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
func check_drop_move_states(cell):
	if figure_in_hand.is_step_possible(cell.coords): # --------------- step possible
		#MOVE FIGURE
		move_figure(cell)
	else: # ---------------------------------------------------------- step impossible
		#DROP FIGURE
		figure_in_hand = null
	clear_cursors()


# move current figure to an another cell
func move_figure(cell):
	figure_in_hand.get_parent().remove_child(figure_in_hand)
	cell.add_child(figure_in_hand)
	
	figure_in_hand.pasition = cell.coords * 100
	
	figure_in_hand.update_coords(board)
	figure_in_hand = null
	is_player_step = false


# switch pawn that moved to another side of the board to queen
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
	
	check_kill_figure_ai(cell)
	figure.get_parent().remove_child(figure)
	cell.add_child(figure)
	figure.update_coords(board)
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
func get_cell(coords):
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
