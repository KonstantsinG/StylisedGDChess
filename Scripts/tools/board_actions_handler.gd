class_name Board_actions_handler
extends Node


func move_figure(figure, cell):
	figure.get_parent().remove_child(figure)
	cell.add_child(figure)


func kill_figure(cell):
	var opposite_figure = cell.get_child(0)
	
	#black_figures.erase(opposite_figure)
	cell.remove_child(opposite_figure)
	opposite_figure.queue_free()
	#move_figure(cell)


var your_team
func _test_state_machine(figure, cell):
	var next_figure
	if cell.get_child_count() == 0:
		next_figure = null
	else:
		next_figure = cell.get_child(0)
	
	if figure == null:
		if next_figure != null and next_figure.team == your_team:
			# TAKE FIGURE
			pass
	else:
		pass
