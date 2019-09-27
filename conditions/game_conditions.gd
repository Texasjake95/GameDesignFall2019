extends Node

#Array of all win conditions to ensure game has been won
var win_conditions = []

#Signal for game won
signal winSignal

#Signal for game lost
signal loseSingal

#TODO make this a find a name and have conditions be named
# PRO: Faster lookup 
# CON: More complex
func findByType(clazz):
	
	for condition in conditions:
		if condition is clazz:
			return condition
	
	return null

#All conditions needed for lookup
var conditions = []

#Add condition to above array
func _registerCondition(condition : BaseCondition):
	conditions.push_back(condition)

#Register win condition 
func addWinCondition(condition : BaseCondition):
	#Listen to condition signal to detect win/lose
	_registerCondition(condition)
	
	#Add condition to win array
	win_conditions.push_back(condition)
	
	#Listen to condition signal to detect win/lose
	condition.connect("condition_signal", self, "_checkWin")

#Register lose condition
func addLoseCondition(condition : BaseCondition):
	#Listen to condition signal to detect win/lose
	_registerCondition(condition)
	#Don't need to special case lose because if one
	#is true game over
	
	#Listen to condition signal to detect win/lose
	condition.connect("condition_signal", self, "loseSignal")

#Called when a win condition is met
func _checkWin(condition : BaseCondition):	

	#If there are no conditions no way to win
	var ret : bool = win_conditions.size() > 0

	#Check all win conditions if one not met then
	#did not win
	for condition in win_conditions:
		if not condition.condition():
			ret = false
			break
	
	#If won let listeners know
	if ret:
		emit_signal("winSignal")

#Called when a lose condition is met
func loseSignal(condition : BaseCondition):
	
	#There is nothing to check just let listeners know 
	#game over
	emit_signal("loseSingal")

#Not sure this is needed cleansup listeners
func disconnectSignal(signalName):
	#Dictionary
	for listener in get_signal_connection_list(signalName):
		disconnect(signalName, listener["target"], listener["method"])

#Needs to be called when scene is changed
func reset():
	win_conditions.clear()
	conditions.clear()
	disconnectSignal("winSignal")
	disconnectSignal("loseSignal")