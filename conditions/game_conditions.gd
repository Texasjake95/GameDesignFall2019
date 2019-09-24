extends Node

var win_conditions = []

signal winSignal
signal loseSingal

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
	condition.connect("condition", self, "_checkWin")
	
func addLoseCondition(condition : BaseCondition):
	_registerCondition(condition)
	#Don't need to special case lose because if one
	#is true game over
	condition.connect("condition", self, "_loseSignal")

func _checkWin(condition : BaseCondition):	
	#Need to figure out a way to make this faster
	var ret : bool = win_conditions.size() > 0
	
	for condition in win_conditions:
		if not condition.condition():
			ret = false
			break
	
	if win_conditions.size() == 0:
		emit_signal("winSignal")

func loseSignal(condition : BaseCondition):
	emit_signal("loseSingal")
	
func disconnectSignal(signalName):
	#Dictionary
	for listener in get_signal_connection_list(signalName):
		disconnect(signalName, listener["target"], listener["method"])
	
func reset():
	win_conditions.clear()
	conditions.clear()
	disconnectSignal("winSignal")
	disconnectSignal("loseSignal")