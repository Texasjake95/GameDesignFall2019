extends Entity_Base

class_name Item

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var itemCondition : ItemCondition

# Called when the node enters the scene tree for the first time.
func _ready():
	itemCondition = game_conditions.findByType(ItemCondition)
	
	if itemCondition != null:
		itemCondition.addItem(self)

func remove():
	queue_free() # ONLY DO THIS IF ALL NODE (CHILDREN INCLUDED) NEED TO BE DELETED
	if itemCondition != null:
		itemCondition.removeItem(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
