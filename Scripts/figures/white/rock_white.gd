extends Chess_figure

var parent
var is_first_step = true

func _ready():
	team = "white"
	type = "rock"
	steps = [[], [], [], []]
	parent = self.get_parent()


# update figure local coords relative board
func update_coords(global_board : Array):
	board = global_board
	coords = self.get_parent().coords
	
	if is_first_step and parent != self.get_parent():
		is_first_step = false


# get steps by unique pattern for current figure
func get_steps_by_pattern():
	for i in range(1, 8):
		steps[0].append(coords + Vector2(i, 0))
		steps[1].append(coords + Vector2(0, i))
		steps[2].append(coords + Vector2(-i, 0))
		steps[3].append(coords + Vector2(0, -i))
