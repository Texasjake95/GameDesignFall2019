extends Node

class_name BaseCollisionManager

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var collisionMappping = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func addMapping(clazz1, clazz2, function : FuncRef):
	var key = [clazz1, clazz2]
	if not collisionMappping.has(key):
		collisionMappping[key] = function

#Check if the entity is invalid and return true if so
func _check(entity):
	return not is_instance_valid(entity) || entity.is_queued_for_deletion()
	
#Override this in subclass
#Check if the collided entities match the given key
func _entities_valid(key, entity1, entity2):
	return false

func _handleCollision(entity1, entity2, collisionData : KinematicCollision2D) -> bool:
	
	if not entity1 || not entity2:
		return false
	
	# Sometimes moveAndSlide does the same node several times if it was removed
	# at any point do not interact again
	if _check(entity1) || _check(entity2):
		return false
	
	var function = null
	
	for key in collisionMappping:
		
		if _entities_valid(key, entity1, entity2):
			function = collisionMappping.get(key)
			break
	
	if not function:
		return false
	
	return function.call_func(entity1, entity2, collisionData)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
