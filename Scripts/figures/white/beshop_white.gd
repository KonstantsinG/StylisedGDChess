extends Chess_figure

func _ready():
	team = "white"
	type = "beshop"
	steps = [[], [], [], []]


# get steps by unique pattern for current figure
func get_steps_by_pattern():
	for i in range(1, 8):
		steps[0].append(coords + Vector2(i, i))
		steps[1].append(coords + Vector2(-i, i))
		steps[2].append(coords + Vector2(i, -i))
		steps[3].append(coords + Vector2(-i, -i))
