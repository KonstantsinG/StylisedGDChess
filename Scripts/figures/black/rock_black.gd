extends Chess_figure

func _ready():
	team = "black"
	type = "rock"
	steps = [[], [], [], []]


# get steps by unique pattern for current figure
func get_steps_by_pattern():
	for i in range(1, 8):
		steps[0].append(coords + Vector2(i, 0))
		steps[1].append(coords + Vector2(0, i))
		steps[2].append(coords + Vector2(-i, 0))
		steps[3].append(coords + Vector2(0, -i))
