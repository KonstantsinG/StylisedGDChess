class_name Chess_AI
extends Node

# class that contains different chess AI models to make decisions of step 

func get_random_model(figures: Array) -> Dictionary:
	var figure = figures.pick_random()
	var steps = []
	while steps.is_empty():
		figure = figures.pick_random()
		steps = figure.get_steps().pick_random()
	var step = steps.pick_random()
	
	var result = {"figure" : figure, "step" : step}
	
	return result


func get_logic_n_steps_forvard_model(n_steps):
	pass
