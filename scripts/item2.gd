extends Item

class_name Item2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("HELLO FROM ITEM2")

func remove():
	print("REMOVED FROM 2")
	.remove() # THIS CALL SUPER?!?!?

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
