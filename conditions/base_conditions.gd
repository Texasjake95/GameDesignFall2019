extends Node

class_name BaseCondition

signal condition_signal

func _ready():
	var type = conditionType()
	if type == "win":
		game_conditions.addWinCondition(self)
	else:
		game_conditions.addLoseCondition(self)

#Fire condition met
func fireEvent():
	emit_signal("condition_signal", self)

#Override this in subclass
func conditionType():
	pass
	
#Override this in subclass
func condition():
	pass