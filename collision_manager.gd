extends Node2D

const collisionMappping = Dictionary()

func _addMapping(clazz1, clazz2, function : String):

	var key = [clazz1, clazz2]
	
	if not collisionMappping.has(key):
		collisionMappping[key] = function
		

# See docs for KinematicBody2D:move_and_collide 
func moveAndCollide(entity : KinematicBody2D, velocity : Vector2, delta,
		infinite_inertia : bool =true, exclude_raycast_shapes : bool =true, test_only : bool =false):
	
	var collision_info = entity.move_and_collide(velocity * delta, infinite_inertia, exclude_raycast_shapes, test_only)
	if collision_info:
		_handleCollision(entity, collision_info.collider, collision_info)

# See docs for KinematicBody2D:move_and_slide 
func moveAndSlide(entity : KinematicBody2D, velocity : Vector2, floor_normal : Vector2 = Vector2( 0, 0 ),
		stop_on_slope : bool = false, max_slides : int =4 , floor_max_angle : float =0.785398, 
		infinite_inertia : bool =true):

	entity.move_and_slide(velocity, floor_normal, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)
	for i in entity.get_slide_count():
		var collision_info = entity.get_slide_collision(i)
		_handleCollision(entity, collision_info.collider, collision_info)

func _check(node):
	return not is_instance_valid(node) || node.is_queued_for_deletion()

func _handleCollision(entity1, entity2, collisionData : KinematicCollision2D):
	
	if not entity1 || not entity2:
		return
	
	# Sometimes moveAndSlide does the same node several times if it was removed
	# at any point do not interact again
	if _check(entity1) || _check(entity2):
		return
	
	var functionName = null
	
	for key in collisionMappping:
		
		var entity1Valid = false
		var entity2Valid = false
		
		for type in key:
			
			if entity1 is type:
				entity1Valid = true
			elif entity2 is type:
				entity2Valid = true	
		
		if entity1Valid and entity2Valid:
			functionName = collisionMappping.get(key)
			break
	
	if not functionName:
		return
	
	call(functionName, entity1, entity2, collisionData)

func _ready():	
	_addMapping(TileMap, Player, "_playerTileHandle")
	_addMapping(Item2, Player, "_playerItemHandle2")
	_addMapping(Item, Player, "_playerItemHandle")

func getType(node):
		
	if node is String:
		return node
		
	var ret = node.get_script()
	if ret:
		return ret
	
	ret = typeof(node)
	return ret

func _playerTileHandle(entity1 : KinematicBody2D, entity2 : KinematicBody2D, collisionData : KinematicCollision2D):
	#TODO call an external script to handle TileMap Entity interaction
	print("TILE HANDLED")
	

func _playerItemHandle2(entity1 : KinematicBody2D, entity2 : KinematicBody2D, collisionData : KinematicCollision2D):

	if not entity1 is Player || not entity2 is Item2:
		return

	var item : Item2 = entity2
	var player : Player = entity1
	
	print("NEW HANDLE")
	
	item.remove()

func _playerItemHandle(entity1 : KinematicBody2D, entity2 : KinematicBody2D, collisionData : KinematicCollision2D):

	if not entity1 is Player || not entity2 is Item:
		return

	var item : Item = entity2
	var player : Player = entity1
	
	item.remove()