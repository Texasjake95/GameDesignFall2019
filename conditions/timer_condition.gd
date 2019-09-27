extends BaseCondition

class_name TimerCondition
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
export var type = "lose"
export(int) var timerLength
var timer : Timer
var timeup = false

func _ready():
	timer = Timer.new()
	#timer.set_wait_time(timerLength)
	timer.connect("timeout", self, "_onTimeout") 
	timer.set_one_shot(true)
	timer.set_autostart(false)
	add_child(timer)
	timer.start(timerLength)

func _onTimeout():
	timeup = true
	fireEvent()
	
func conditionType():
	return type

func condition():
	return timeup

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
