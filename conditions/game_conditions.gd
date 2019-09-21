extends Node

var win_conditions = []
var lose_conditions = []

func findByType(clazz):
	
	for condition in conditions:
		if condition is clazz:
			return condition
	
	return null

var conditions = []

func _registerCondition(condition : BaseCondition):
	conditions.push_back(condition)

func addWinCondition(condition : BaseCondition):
	_registerCondition(condition)
	win_conditions.push_back(condition)
	
func addLoseCondition(condition : BaseCondition):
	_registerCondition(condition)
	lose_conditions.push_back(condition)

func reset():
	win_conditions.clear()
	lose_conditions.clear()
	conditions.clear()

func hasWon() -> bool:
	var ret : bool = win_conditions.size() > 1
	
	for condition in win_conditions:
		if not condition.condition():
			ret = false
			break
	
	return ret
	
func hasLoss() -> bool:
	var ret : bool = false
	
	for condition in lose_conditions:
		if condition.condition():
			ret = true
			break
			
	return ret