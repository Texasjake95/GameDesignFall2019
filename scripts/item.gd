extends Entity_Base

class_name Item

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("HELLO FROM ITEM")



func remove():
	get_parent().remove_child(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass