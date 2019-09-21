extends Node

class_name BaseCondition

func _ready():

	var type = conditionType()
	if type == "win":
		game_conditions.addWinCondition(self)
	else:
		game_conditions.addLoseCondition(self)
	

func conditionType():
	pass

func condition():
	pass