extends Chess_figure

func _ready():
	team = "white"
	type = "horse"
	steps = [[]]


# get steps by unique pattern for current figure
func get_steps_by_pattern():
	steps[0].append(coords + Vector2(1, 2))
	steps[0].append(coords + Vector2(-1, 2))
	steps[0].append(coords + Vector2(1, -2))
	steps[0].append(coords + Vector2(-1, -2))
	
	steps[0].append(coords + Vector2(2, 1))
	steps[0].append(coords + Vector2(-2, 1))
	steps[0].append(coords + Vector2(2, -1))
	steps[0].append(coords + Vector2(-2, -1))


# find extra coords in the line blocked by another figure
func find_blocked_coords(corpses: Array[Vector2]):
	var cell
	
	for coord in steps[0]:
		if not corpses.has(coord):
			cell = get_cell(coord)
			if cell.get_child_count() > 0:
				if cell.get_child(0).team == team:
					corpses.append(coord)
